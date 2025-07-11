//
//  PuzzleLevelRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

struct PuzzleLevelRoutes {
    let controller = PuzzleLevelController()
    
    func register(on routes: any RoutesBuilder) {
        let levels = routes.grouped("puzzle").grouped("levels")
        
        // 关卡管理
        levels.post(use: controller.create)
        levels.get(use: controller.getAll)
        levels.get("detail", use: controller.show)
        levels.post("update", use: controller.update)
        levels.delete("delete", use: controller.delete)
        
        // 关卡配置管理
        levels.group("configs") { configGroup in
            configGroup.post(use: controller.createConfig)
            configGroup.get(use: controller.getConfigs)
        }
        
        // 关卡奖励管理
        levels.group("rewards") { rewardGroup in
            rewardGroup.post(use: controller.createReward)
            rewardGroup.get(use: controller.getRewards)
        }
    }
}
