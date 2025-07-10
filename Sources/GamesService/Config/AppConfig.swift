//
//  File.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor
import Fluent

/// 根配置模型（对应整个 JSON 文件）
public struct AppConfig: Content {
    let app: AppSettings
    let database: DatabaseConfig
    let auth: AuthConfig
}

/// 应用基本设置
public struct AppSettings: Content {
    let name: String
    let apiPrefix: String
}

/// 数据库配置
public struct DatabaseConfig: Content {
    let hostname: String
    let port: Int
    let username: String
    let password: String
    let database: String
    let url: String
    let maxConnections: Int
}

/// 认证配置
public struct AuthConfig: Content {
    let jwtSecret: String
}

public func getAppConfig(_ app: Application) throws -> AppConfig? {
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
        throw Abort(.expectationFailed)
    }
        
    // 解析 JSON
    return try JSONDecoder().decode(AppConfig.self, from: fileData)
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
