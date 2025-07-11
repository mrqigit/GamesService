//
//  RoleRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

struct RoleRoutes {
    let controller = RoleController()
    
    func register(on routes: any RoutesBuilder) {
        let roles = routes.grouped("roles")
        
        roles.get(use: controller.index)
        roles.post(use: controller.create)
        roles.get("detail",use: controller.show)
        roles.post("update",use: controller.update)
        roles.post("delete",use: controller.delete)
    }
}
