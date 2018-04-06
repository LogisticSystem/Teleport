//
//  Message.swift
//  TeleportPackageDescription
//
//  Created by Наталия Волкова on 06.04.2018.
//

import Vapor

final class Message: Codable {
    // MARK: - Публичные свойства
    
    ///
    let action: String
    ///
    let transportId: String
    ///
    let storageId: String
    ///
    let capacity: Int
    ///
    let products: [Product]?
    ///
    let percent: Int?
    
    init(action: String, transportId: String, storageId: String, capacity: Int, products: [Product]?, percent: Int?) {
        self.action = action
        self.transportId = transportId
        self.storageId = storageId
        self.capacity = capacity
        self.products = products
        self.percent = percent
    }
    
}


extension Message: Content { }
