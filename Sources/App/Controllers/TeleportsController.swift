import Vapor

struct TeleportsController {
    
    private let configsUrl = "http://localhost:8080/teleports.json"
    
}


// MARK: - Приватные методы

private extension TeleportsController {
    
    func configureHandler(_ request: Request) throws -> Future<[Teleport]> {
        return try request.make(Client.self).get(self.configsUrl).flatMap(to: [Teleport].self) { response in
            return try response.content.decode(TeleportsConfig.self).map(to: [Teleport].self) { teleportsConfig in
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
    
}


// MARK: - RoutrCollection

extension TeleportsController: RouteCollection {
    
    func boot(router: Router) throws {
        let teleportsController = router.grouped("teleports")
        teleportsController.put(use: configureHandler)
        teleportsController.get(use: getAllHandler)
    }
    
}
