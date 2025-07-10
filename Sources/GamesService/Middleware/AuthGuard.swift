//
//  AuthGuard.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

struct AuthGuard: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard request.auth.has(User.self) else {
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}
