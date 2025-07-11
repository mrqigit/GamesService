//
//  PuzzleLevelRewardDTO.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 关卡奖励相关DTO
struct PuzzleLevelRewardDTO {
    struct Create: Content, Validatable {
        let levelID: UUID
        let rewardType: Int
        let rewardAmount: Int
        let rewardCondition: Int
        
        static func validations(_ validations: inout Validations) {
            validations.add("levelID", as: UUID.self)
            validations.add("rewardType", as: Int.self)
            validations.add("rewardAmount", as: Int.self)
            validations.add("rewardCondition", as: Int.self)
        }
    }
    
    struct Response: Content {
        let id: UUID?
        let levelID: UUID
        let rewardType: Int
        let rewardAmount: Int
        let rewardCondition: Int
        let createdAt: Date?
        
        init(from model: PuzzleLevelReward) {
            self.id = model.id
            self.levelID = model.$level.id
            self.rewardType = model.rewardType
            self.rewardAmount = model.rewardAmount
            self.rewardCondition = model.rewardCondition
            self.createdAt = model.createdAt
        }
    }
}
