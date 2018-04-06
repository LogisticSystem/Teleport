//
//  webSocketRoutes.swift
//  TeleportPackageDescription
//
//  Created by Наталия Волкова on 06.04.2018.
//

import Vapor

func webSocketRoutes(_ server: EngineWebSocketServer) {
    
    server.get("socket") { webSocket, request in
        guard let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop else { return }
        
        let loggerService = try request.make(LoggerService.self)
        loggerService.subscribe(webSocket, on: eventLoop) { message in
            webSocket.send(message)
        }
        
        webSocket.onClose {
            loggerService.unsubscribe(webSocket)
        }
    }
}
