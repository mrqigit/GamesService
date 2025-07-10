//
//  AdminMiddleware.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor

struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let user = try request.auth.require(User.self)
        let role = try await user.$role.get(on: request.db)
        guard role.type == "admin" else {
            throw Abort(.forbidden, reason: "仅管理员可操作")
        }
        return try await next.respond(to: request)
    }
}
