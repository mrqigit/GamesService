//
//  DatabaseConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor
import FluentPostgresDriver

public func configureDatabase(_ app: Application, config: AppConfig) {
    // 在configure.swift中配置连接池
    let configuration = SQLPostgresConfiguration.init(hostname: config.database.hostname,
                                                      port: config.database.port,
                                                      username: config.database.username,
                                                      password: config.database.password,
                                                      database: config.database.database,
                                                      tls: .disable)
    
    // 数据库连接
    app.databases.use(.postgres(configuration:configuration),as: .psql)
}
