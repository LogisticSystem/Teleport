import Vapor

final class CheckProductsRequest: Codable {
    
    // MARK: - Публичные свойства
    
    var capacity: Int?
    var accessiblePoints: [String]?
    
    
    // MARK: - Инициализация
    
    init(capacity: Int?, accessiblePoints: [String]?) {
        self.capacity = capacity
        self.accessiblePoints = accessiblePoints
    }
    
}


// MARK: - Content

extension CheckProductsRequest: Content { }
