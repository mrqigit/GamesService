//
//  JWTConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor
import JWT

public func configureJWT(_ app: Application, config: AppConfig) {
    // 配置 Bcrypt 哈希器
    app.passwords.use(.bcrypt)
        
    // 从环境变量或配置文件获取密钥（安全实践）
    let key = Data(config.auth.jwtSecret.utf8)

    // 配置JWT签名（HS256算法）
    app.jwt.signers.use(.hs256(key: key)) // 密钥长度至少32字节
}
