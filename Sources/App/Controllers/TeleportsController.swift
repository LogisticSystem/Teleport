import Vapor

struct TeleportsController {
    
    private let configsUrl = "http://localhost:8080/teleports.json"
    
}


// MARK: - Приватные методы

private extension TeleportsController {
    
    func configureHandler(_ request: Request) throws -> Future<[Teleport]> {
        
        // Отправка запроса на получение настроек телепорта
        return try request.make(Client.self).get(self.configsUrl).flatMap(to: [Teleport].self) { response in
            return try response.content.decode(TeleportsConfig.self).map(to: [Teleport].self) { teleportsConfig in
                
                // Сохранение настроек
                let teleportsService = try request.make(TeleportsService.self)
                teleportsService.configure(with: teleportsConfig.teleports)
                
                return teleportsConfig.teleports
            }
        }
    }
    
    func getAllHandler(_ request: Request) throws -> [Teleport] {
        let teleportsService = try request.make(TeleportsService.self)
        return teleportsService.getAll()
    }
    
    func checkHandler(_ request: Request) throws -> Future<HTTPStatus> {
        let promise = request.eventLoop.newPromise(Void.self)
        
        DispatchQueue.global().async {
            do {
                let dispatchGroup = DispatchGroup()
                
                let teleportsService = try request.make(TeleportsService.self)
                let teleports = teleportsService.getAll()
                
                for teleport in teleports {
                    let index = Random.roll(max: teleport.availableStorages.count)
                    let storageId = teleport.availableStorages[index]
                    
                    dispatchGroup.enter()
                    _ = try? self.checkStorage(request, storageId: storageId, teleport: teleport).map(to: Void.self) { _ in
                        
                        // Составляем словарь, в котором ключ - склад, а значение - массив товаров, которые необходимо доставить до этого склада
                        var tmp: [String: [Product]] = [:]
                        for product in teleport.products {
                            
                            // Из маршрута получаем идентификатор следующей точки назначения
                            guard let nextPoint = product.route.first, let _nextPointId = nextPoint.split(separator: "|").first else { continue }
                            let nextPointId = String(_nextPointId)
                            
                            // Записываем товар в словарь
                            if tmp[nextPointId] == nil {
                                tmp[nextPointId] = []
                            }
                            
                            tmp[nextPointId]?.append(product)
                        }
                        
                        // Получить ключ, для которого в словаре наибольшее количество элементов
                        guard let result = tmp.max(by: { $0.value.count < $1.value.count }) else {
                            dispatchGroup.leave()
                            return
                        }
                        
                        // Удаляем данные
                        teleportsService.remove(result.value, inTeleport: teleport.id)
                        
                        // Отправляем запрос на отгрузку
                        _ = try? self.deliverProducts(request, products: result.value, destinationStorage: result.key, in: teleport).map(to: Void.self) { response in
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.wait()
                
                promise.succeed()
            } catch {
                promise.fail(error: error)
            }
        }
        
        return promise.futureResult.transform(to: .ok)
    }
    
    func checkStorage(_ request: Request, storageId: String, teleport: Teleport) throws -> Future<Void> {
        
        // Идентификатор транспорта
        let transportId = "teleport-\(teleport.id)"
        
        // Логирование
        let loggerService = try request.make(LoggerService.self)
        
        let message = Message(action: "getItems", transportId: transportId, storageId: storageId, capacity: .max, products: nil, percent: nil)
        try loggerService.log(message)
        
        // Отправка запроса на получение товаров для транспортировки со склада
        let content = CheckProductsRequest(capacity: nil, accessiblePoints: teleport.availableStorages.filter { $0 != storageId }, transportId: transportId)
        return try request.make(Client.self).post("http://188.225.9.3/storages/\(storageId)/products/prepare", content: content).flatMap(to: Void.self) { response in
            return try response.content.decode(CheckProductsResponse.self).flatMap(to: Void.self) { productsResponse in
                
                if !productsResponse.products.isEmpty {
                    
                    // Логирование
                    let loggerService = try request.make(LoggerService.self)
                
                    let message = Message(action: "gotItems", transportId: transportId, storageId: storageId, capacity: .max, products: productsResponse.products, percent: 0)
                    try loggerService.log(message)
                }
                
                // Отправка запроса на смену владельца товара
                let content = ProductsUpdateOwnerContainer(products: productsResponse.products)
                return try request.make(Client.self).put("http://188.225.9.3/products/owner/\(transportId)", content: content).flatMap(to: Void.self) { response in
                    return try response.content.decode(ProductsUpdateOwnerContainer.self).map(to: Void.self) { productsContainer in
                        
                        // Сохранить в массив у телепорта
                        let teleportsService = try request.make(TeleportsService.self)
                        teleportsService.put(productsContainer.products, inTeleport: teleport.id)
                        
                        return
                    }
                }
            }
        }
    }
    
    func deliverProducts(_ request: Request, products: [Product], destinationStorage: String, in teleport: Teleport) throws -> Future<Void> {
        
        // Идентификатор транспорта
        let transportId = "teleport-\(teleport.id)"
        
        // Логирование
        let loggerService = try request.make(LoggerService.self)
        
        let message = Message(action: "giveItems", transportId: transportId, storageId: destinationStorage, capacity: .max, products: products, percent: nil)
        try loggerService.log(message)
        
        // Отправка запроса на сброс владельца
        let content = ProductsUpdateOwnerContainer(products: products)
        return try request.make(Client.self).put("http://188.225.9.3/products/owner/", content: content).flatMap(to: Void.self) { response in
            return try response.content.decode(ProductsUpdateOwnerContainer.self).flatMap(to: Void.self) { productsContainer in
                
                // Логирование
                let loggerService = try request.make(LoggerService.self)
                
                let message = Message(action: "gaveItems", transportId: transportId, storageId: destinationStorage, capacity: .max, products: productsContainer.products, percent: 100)
                try loggerService.log(message)
                
                // Отправка запроса на передачу складу
                let content = DeliverToStorageRequest(products: productsContainer.products, transportId: transportId)
                return try request.make(Client.self).post("http://188.225.9.3/storages/\(destinationStorage)/products", content: content).map(to: Void.self) { response in
                    return
                }
            }
        }
    }
    
}


// MARK: - RoutrCollection

extension TeleportsController: RouteCollection {
    
    func boot(router: Router) throws {
        let teleportsController = router.grouped("teleports")
        teleportsController.put(use: configureHandler)
        teleportsController.get(use: getAllHandler)
        teleportsController.get("check", use: checkHandler)
    }
    
}
