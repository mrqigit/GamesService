//
//  UserToken.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent
import Vapor
import JWTKit

final class UserToken: Model, Content, Authenticatable, JWTPayload, @unchecked Sendable {
    
    static let schema = "user_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "expires_at", on: .none)
    var expiresAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, value: String, userID: UUID, expiresAt: Date? = nil) {
        self.id = id
        self.value = value
        self.$user.id = userID
        self.expiresAt = expiresAt
    }
    
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        if expiresAt == nil {
            throw Abort(.expectationFailed)
        }
        guard let expiresAt = expiresAt else { return }
        try ExpirationClaim(value: expiresAt).verifyNotExpired()
    }
}

extension User {
    func generateToken() throws -> UserToken {
        // 生成随机字节
        let randomBytes = [UInt8].random(count: 32)
        
        // ✅ 使用 Data 的 base64EncodedString 方法
        let token = Data(randomBytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")  // 替换不安全字符
            .replacingOccurrences(of: "/", with: "_")  // 替换不安全字符
            .replacingOccurrences(of: "=", with: "")   // 移除填充字符
        
        // 设置令牌有效期（例如7天）
        let expiresAt = Date().addingTimeInterval(7 * 24 * 60 * 60)
        
        return UserToken(
            value: token,
            userID: try requireID(),
            expiresAt: expiresAt
        )
    }
}
