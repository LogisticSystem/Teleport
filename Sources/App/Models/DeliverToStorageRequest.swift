import Vapor

final class DeliverToStorageRequest : Codable {
    
    // MARK: - Публичные свойства
    
    var products: [Product]
    var transportId: String
    
    
    // MARK: - Инициализация
    
    init(products: [Product], transportId: String) {
        self.products = products
        self.transportId = transportId
    }
    
}


// MARK: - Content

extension DeliverToStorageRequest: Content { }
