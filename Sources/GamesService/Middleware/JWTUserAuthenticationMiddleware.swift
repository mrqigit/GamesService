//
//  JWTUserAuthenticationMiddleware.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor
import JWT

struct JWTUserAuthenticationMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let tokenString = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }
        
        // 显式指定 JWT 类型
        let payload = try request.jwt.verify(tokenString, as: UserPayload.self)
        
        // 显式转换 UUID
        guard let userId = UUID(uuidString: payload.sub.value),
              let user = try await User.find(userId, on: request.db) else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user)
        return try await next.respond(to: request)
    }
}
