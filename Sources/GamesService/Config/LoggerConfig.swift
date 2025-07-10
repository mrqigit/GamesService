//
//  LogerConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor

public func configureLogger(_ app: Application) {
    // 在configure.swift中配置日志级别
    app.logger.logLevel = .trace

    // 记录详细错误
    app.middleware.use(
        ErrorMiddleware {
            error,
            req in
            // 其他错误处理...
            app.logger.info(.init(stringLiteral: error.description))
            return Response(
                status: .internalServerError,
                body: .init(string: error.description)
            )
        })
}
