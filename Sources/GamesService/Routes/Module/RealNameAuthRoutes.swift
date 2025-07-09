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
        
        realNames.group(":id") { realName in
            realName.get(use: controller.show)
            realName.put(use: controller.update)
            realName.delete(use: controller.delete)
            realName.patch(use: controller.update)
        }
    }
}
