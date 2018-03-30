import Vapor

final class Teleport {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор телепорта
    let id: Int
    /// Достижимые склады
    let availableStorages: [String]
    /// Товары
    var products: [Product] = []
    
    
    // MARK: - Инициализация
    
    init(id: Int, availableStorages: [String]) {
        self.id = id
        self.availableStorages = availableStorages
    }
    
}
