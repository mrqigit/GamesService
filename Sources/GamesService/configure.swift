import Vapor
import Fluent
import FluentPostgresDriver
import JWTKit

// configures your application
public func configure(_ app: Application) async throws {
        
    // 获取当前环境名称（如 "development", "production"）
    let envName = app.environment.name
        
    // 构建配置文件名（如 "development.json"）
    let fileName = envName + ".json"
        
    // 构建配置文件路径
    let configDir = app.directory.workingDirectory + "Config/"
    let filePath = configDir + fileName
        
    // 使用 FileManager 同步读取文件内容
    guard let fileData = FileManager.default.contents(atPath: filePath) else {
        // 如果特定环境的配置文件不存在，尝试加载 default.json
        let defaultFilePath = configDir + "default.json"
        guard let defaultFileData = FileManager.default.contents(atPath: defaultFilePath) else {
            fatalError("无法加载配置文件: \(filePath) 或 \(defaultFilePath)")
        }
        let decoder = JSONDecoder()
        let config = try decoder.decode(AppConfig.self, from: defaultFileData)
        app.storage[AppConfigKey.self] = config
        return
    }
        
    // 解析 JSON
    let decoder = JSONDecoder()
    let config = try decoder.decode(AppConfig.self, from: fileData)
    
    // 公共资源配置
    app.middleware
        .use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // 在configure.swift中配置连接池
    let configuration = SQLPostgresConfiguration.init(hostname: config.database.hostname,
                                                      port: config.database.port,
                                                      username: config.database.username,
                                                      password: config.database.password,
                                                      database: config.database.database,
                                                      tls: .disable)
    
    // 数据库连接
    app.databases.use(.postgres(configuration:configuration),as: .psql)
    
    // 在configure.swift中配置日志级别
    app.logger.logLevel = .debug

    // 记录详细错误
    app.middleware.use(
        ErrorMiddleware {
            error,
            req in
            // 其他错误处理...
            app.logger.info(.init(stringLiteral: error.description))
            return Response(
                status: .internalServerError,
                body: .init(string: error.description)
            )
        })
    
    // 配置 Bcrypt 哈希器
    app.passwords.use(.bcrypt)
        
    // 从环境变量或配置文件获取密钥（安全实践）
    let key = Data(config.auth.jwtSecret.utf8)
    
    // 配置 HMAC-SHA256 签名器
    let signer = JWTSigner.hmac(key: key, algorithm: .hs256)
    app.jwt.signers.use(signer)
    
    // 注册 JWT 认证中间件
    app.middleware.use(UserToken.authenticator())
    app.middleware.use(User.guardMiddleware())
    
    /// 角色表迁移
    app.migrations.add(CreateRoles())
    // 注册实名认证表迁移
    app.migrations.add(CreateRealNameAuth())
    
    /// 注册路由
    try APIRoutes(app: app).registerRoutes(prefix: config.app.apiPrefix)
}

// 用于在应用中存储配置的键
private struct AppConfigKey: StorageKey {
    typealias Value = AppConfig
}

// 在应用中访问配置的扩展
extension Application {
    var appConfig: AppConfig {
        guard let config = storage[AppConfigKey.self] else {
            fatalError("配置未加载")
        }
        return config
    }
}
