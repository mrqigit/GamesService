//
//  File.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

/// 根配置模型（对应整个 JSON 文件）
struct AppConfig: Content {
    let app: AppSettings
    let database: DatabaseConfig
    let auth: AuthConfig
}

/// 应用基本设置
struct AppSettings: Content {
    let name: String
    let apiPrefix: String
}

/// 数据库配置
struct DatabaseConfig: Content {
    let hostname: String
    let port: Int
    let username: String
    let password: String
    let database: String
    let url: String
    let maxConnections: Int
}

/// 认证配置
struct AuthConfig: Content {
    let jwtSecret: String
}
