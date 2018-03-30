import Foundation
import Vapor

struct TeleportsController {
    
    private let configsUrl = "http://localhost:8080/teleports.json"
    
    init() {
        #if os(Linux)
            srandom(UInt32(time(nil)))
        #endif
    }
    
}


// MARK: - Приватные методы

private extension TeleportsController {
    
    func generateRandom(max: Int) -> Int {
        #if os(Linux)
            return Int(random() % max)
        #else
            return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
    
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
                    let index = self.generateRandom(max: teleport.availableStorages.count)
                    let storageId = teleport.availableStorages[index]
                    
                    dispatchGroup.enter()
                    _ = try? self.checkStorage(request, storageId: storageId, teleport: teleport).map(to: Void.self) { _ in
                        dispatchGroup.leave()
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
        
        // Отправка запроса на получение товаров для транспортировки со склада
        let content = CheckProductsRequest(capacity: nil, accessiblePoints: teleport.availableStorages.filter { $0 != storageId })
        return try request.make(Client.self).post("http://188.225.9.3/storages/\(storageId)/products/prepare", content: content).flatMap(to: Void.self) { response in
            return try response.content.decode(CheckProductsResponse.self).flatMap(to: Void.self) { productsResponse in
                
                // Отправка запроса на смену владельца товара
                let content = ProductsUpdateOwnerContainer(products: productsResponse.products)
                return try request.make(Client.self).put("http://188.225.9.3/products/owner/teleport-\(teleport.id)", content: content).flatMap(to: Void.self) { response in
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
