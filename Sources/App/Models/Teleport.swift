import Vapor

final class Teleport: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор телепорта
    var id: Int
    /// Достижимые склады
    var availableStorages: [String]
    /// Товары
    var products: [Product]!
    
    
    // MARK: - Инициализация
    
    init(id: Int, availableStorages: [String]) {
        self.id = id
        self.availableStorages = availableStorages
        self.products = []
    }
    
}


// MARK: - Content

extension Teleport: Content { }
