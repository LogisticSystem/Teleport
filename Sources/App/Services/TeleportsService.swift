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
    
}

// MARK: - Service
extension TeleportsService: Service { }
