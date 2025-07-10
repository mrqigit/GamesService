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
        
        users.group(":id") { user in
            user.get(use: controller.show)
            user.put(use: controller.update)
            user.delete(use: controller.delete)
            user.patch(use: controller.update)
        }
    }
}

