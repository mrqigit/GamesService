//
//  RealNameAuthRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

struct RealNameAuthRoutes {
    let controller = RealNameAuthController()
    
    func register(on routes: any RoutesBuilder) {
        let realNames = routes.grouped("real_name_auths")
        
        realNames.get(use: controller.index)
        realNames.post(use: controller.create)
        realNames.get("detail",use: controller.show)
        realNames.post("update",use: controller.update)
        realNames.post("delete",use: controller.delete)
    }
}
