import Vapor
import Fluent

// configures your application
public func configure(_ app: Application) async throws {
    
    // 公共资源配置
    app.middleware
        .use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    guard let config = try getAppConfig(app) else {
        throw Abort(.badGateway, reason: "服务配置文件解析失败")
    }
    
    // 配置数据库
    configureDatabase(app,config: config)
    
    // 配置日志
    configureLogger(app)
    
    // 配置JWT
//    configureJWT(app,config: config)
//    
//    // 表迁移
//    configureMigrations(app)
//    
//    // 配置中间件
//    configureMiddleware(app)
    
    /// 注册路由
    app.http.server.configuration.port = 8890

    try APIRoutes(app: app).registerRoutes(prefix: config.app.apiPrefix)
}
