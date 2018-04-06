import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register routes to the WebSocket router
    let webSocketRouter = EngineWebSocketServer.default()
    webSocketRoutes(webSocketRouter)
    services.register(webSocketRouter, as: WebSocketServer.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Registration services
    services.register(TeleportsService())
    services.register(LoggerService())
    
}
