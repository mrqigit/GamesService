//
//  ErrorHandlingMiddleware.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor

// 定义错误处理中间件
struct ErrorHandlingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let abort as Abort {
            // 统一错误响应格式
            return Response(
                status: abort.status,
                body: .init(string: ["error": abort.reason].toJsonString)
            )
        } catch {
            return Response(
                status: .internalServerError,
                body: .init(string: ["error": "服务器内部错误"].toJsonString)
            )
        }
    }
}
