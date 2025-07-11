//
//  UserPayload.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import JWT
import Vapor
import Fluent

// 遵循 JWT 负载和认证协议
struct UserPayload: JWTPayload, Authenticatable {
    let sub: SubjectClaim
    let exp: ExpirationClaim
    let iat: IssuedAtClaim
    let username: String
    let userId: UUID?
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
        // ✅ 手动验证签发时间是否在未来
        if iat.value > .now {
            throw JWTError.claimVerificationFailure(name: "future", reason: "Token issued in the future")
        }
    }
    
    init(user: User, expirationDuration: TimeInterval = 86400) throws {
        self.sub = .init(value: try user.requireID().uuidString)
        self.exp = .init(value: .now + expirationDuration)
        self.iat = .init(value: .now)
        self.username = user.username
        self.userId = user.id
    }
}
