import Vapor

final class TeleportsConfig: Codable {
    
    // MARK: - Публичные свойства
    
    var teleports: [Teleport]
    
}


// MARK: - Content

extension TeleportsConfig: Content { }
