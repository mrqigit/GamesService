//
//  UserRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

struct UserRoutes {
    let controller = UserController()
    
    func register(on routes: any RoutesBuilder) {
        let users = routes.grouped("users")
        
        users.get(use: controller.index)
        users.post(use: controller.create)
        users.post("login", use: controller.login)
        users.post("update", use: controller.update)
        users.post("delete", use: controller.delete)
        users.get("detail",use: controller.show)
    }
}

