import Vapor

final class ProductsUpdateOwnerContainer: Codable {
    
    // MARK: - Публичные свойства
    
    var products: [Product]
    
    
    // MARK: - Инициализация
    
    init(products: [Product]) {
        self.products = products
    }
    
}


// MARK: - Content

extension ProductsUpdateOwnerContainer: Content { }

