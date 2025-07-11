//
//  APIRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

struct APIRoutes {
    let app: Application
    
    func registerRoutes(prefix: String) throws {
        let api = app.routes
            .grouped(PathComponent(stringLiteral: prefix))
            .grouped(ErrorHandlingMiddleware())
            .grouped(JWTUserAuthenticationMiddleware())
        
        // 注册各个模块的路由
        RoleRoutes().register(on: api.grouped("app"))
        RealNameAuthRoutes().register(on: api.grouped("app"))
        UserRoutes().register(on: api.grouped("app"))
        AdvertisementRoutes().register(on: api.grouped("app"))
        SignInRoutes().register(on: api.grouped("app"))
        SignInConfigRoutes().register(on: api.grouped("app"))
        PuzzleLevelRoutes().register(on: api.grouped("app"))
        UserPuzzleLevelRoutes().register(on: api.grouped("app"))
    }
}
