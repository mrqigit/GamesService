//
//  UserPuzzleLevelRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

struct UserPuzzleLevelRoutes {
    let controller = UserPuzzleProgressController()
    
    func register(on routes: any RoutesBuilder) {
        let progress = routes.grouped("puzzle").grouped("progress")
        
        progress.post(use: controller.create)
        progress.get(use: controller.getAll)
        progress.get("detail", use: controller.show)
        progress.post("update", use: controller.update)
        progress.delete("delete", use: controller.delete)
        
        // 获取用户所有关卡进度
        progress.group("user") { userGroup in
            userGroup.get(use: controller.getUserProgress)
        }
        
        // 获取关卡所有用户进度
        progress.group("level") { levelGroup in
            levelGroup.get(use: controller.getLevelProgress)
        }
    }
}
