import Vapor

final class CheckProductsRequest: Codable {
    
    // MARK: - Публичные свойства
    
    var capacity: Int?
    var accessiblePoints: [String]?
    var transportId: String
    
    
    // MARK: - Инициализация
    
    init(capacity: Int?, accessiblePoints: [String]?, transportId: String) {
        self.capacity = capacity
        self.accessiblePoints = accessiblePoints
        self.transportId = transportId
    }
    
}


// MARK: - Content

extension CheckProductsRequest: Content { }
