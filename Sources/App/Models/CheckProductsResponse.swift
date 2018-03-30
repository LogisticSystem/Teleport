import Vapor

final class CheckProductsResponse : Codable {
    
    // MARK: - Публичные свойства
    
    var products: [Product]
    
    
    // MARK: - Инициализация
    
    init(products: [Product]) {
        self.products = products
    }
    
}


// MARK: - Content

extension CheckProductsResponse: Content { }
