import Vapor

final class Product: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор товара
    let id: String
    /// Отправитель товара
    let source: String
    /// Целевой склад
    let destination: String
    /// Маршрут доставки
    let route: [String]
    
    
    // MARK: - Инициализация
    
    init(id: String, source: String, destination: String, route: [String]) {
        self.id = id
        self.source = source
        self.destination = destination
        self.route = route
    }
    
}


// MARK: - Content
extension Product: Content { }
