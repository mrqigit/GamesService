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
        
        roles.group(":id") { role in
            role.get(use: controller.show)
            role.put(use: controller.update)
            role.delete(use: controller.delete)
            role.patch(use: controller.update)
        }
    }
}
