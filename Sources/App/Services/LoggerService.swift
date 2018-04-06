//
//  LoggerService.swift
//  TeleportPackageDescription
//
//  Created by Наталия Волкова on 06.04.2018.
//

import Vapor

private final class LogSubscriber {
    
    // MARK: - Публичные свойства
    
    /// Сокет
    let webSocket: WebSocket
    /// Очередь
    let eventLoop: EventLoop
    /// Обработчик
    let handler: (Data) -> Void
    
    
    // MARK: - Инициализация
    
    init(webSocket: WebSocket, eventLoop: EventLoop, handler: @escaping (Data) -> Void) {
        self.webSocket = webSocket
        self.eventLoop = eventLoop
        self.handler = handler
    }
    
}

final class LoggerService: Service {
    
    // MARK: - Приватные свойства
    
    /// Подписчики
    private var subscribers = SynchronizedValue([LogSubscriber]())
    
    
    // MARK: - Публичные методы
    
    /// Подписаться
    func subscribe(_ webSocket: WebSocket, on eventLoop: EventLoop, subscriptionHandler handler: @escaping (Data) -> Void) {
        let subscriber = LogSubscriber(webSocket: webSocket, eventLoop: eventLoop, handler: handler)
        self.subscribers.syncSet { subscribers in
            subscribers.append(subscriber)
        }
    }
    
    /// Отписаться
    func unsubscribe(_ webSocket: WebSocket) {
        self.subscribers.syncSet { subscribers in
            guard let index = subscribers.index(where: { $0.webSocket === webSocket }) else { return }
            subscribers.remove(at: index)
        }
    }
    
    /// Логировать
    func log<T : Encodable>(_ message: T) throws {
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(message)
        
        self.subscribers.syncSet { subscribers in
            subscribers.forEach { subscriber in
                subscriber.eventLoop.execute {
                    subscriber.handler(data)
                }
            }
        }
    }
    
}
