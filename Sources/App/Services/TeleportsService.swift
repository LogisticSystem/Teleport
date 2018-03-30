import Vapor

final class TeleportsService {
    
    // MARK: - Приватные свойства
    
    private var teleports = SynchronizedValue([Teleport]())
}


// MARK: - Публичные методы

extension TeleportsService {
    
    func configure(with teleports: [Teleport]) {
        self.teleports.syncSet { tmpTeleports in
            tmpTeleports = teleports
        }
    }
    
    func getAll() -> [Teleport] {
        return self.teleports.get()
    }
    
    func put(_ products: [Product], inTeleport teleportId: Int) {
        self.teleports.syncSet { teleports in
            guard let teleportIndex = teleports.index(where: { $0.id == teleportId }) else { return }
            let teleport = teleports[teleportIndex]
            
            teleport.products.append(contentsOf: products)
        }
    }
    
    func remove(_ products: [Product], inTeleport teleportId: Int) {
        self.teleports.syncSet { teleports in
            guard let teleportIndex = teleports.index(where: { $0.id == teleportId }) else { return }
            let teleport = teleports[teleportIndex]
            
            for product in products {
                guard let productIndex = teleport.products.index(where: { $0.id == product.id }) else { continue }
                teleport.products.remove(at: productIndex)
            }
        }
    }
    
}

// MARK: - Service
extension TeleportsService: Service { }
