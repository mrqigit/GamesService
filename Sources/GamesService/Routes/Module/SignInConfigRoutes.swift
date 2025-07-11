//
//  SignInConfigRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

struct SignInConfigRoutes {
    let controller = SignInConfigController()
    
    func register(on routes: any RoutesBuilder) {
        let config = routes.grouped("signConfig")
        
        config.post(use: controller.createConfig)
        config.get(use: controller.getAllConfigs)
        config.get("detail", use: controller.getConfig)
        config.post("update", use: controller.updateConfig)
        config.delete("delete", use: controller.deleteConfig)
    }
}
