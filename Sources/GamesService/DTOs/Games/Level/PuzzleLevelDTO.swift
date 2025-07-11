//
//  PuzzleLevelDTO.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 关卡相关DTO
struct PuzzleLevelDTO {
    struct Create: Content, Validatable {
        let levelNumber: Int
        let title: String
        let difficulty: Int
        let gridSize: String
        let imageUrl: String
        let timeLimit: Int?
        let movesLimit: Int?
        let isPremium: Bool
        let status: Int
        
        static func validations(_ validations: inout Validations) {
            validations.add("levelNumber", as: Int.self)
            validations.add("title", as: String.self)
            validations.add("difficulty", as: Int.self)
            validations.add("gridSize", as: String.self)
            validations.add("imageUrl", as: String.self)
            validations.add("isPremium", as: Bool.self)
            validations.add("status", as: Int.self)
        }
    }
    
    struct Response: Content {
        let id: UUID?
        let levelNumber: Int
        let title: String
        let difficulty: Int
        let gridSize: String
        let imageUrl: String
        let timeLimit: Int?
        let movesLimit: Int?
        let isPremium: Bool
        let status: Int
        let createdAt: Date?
        let updatedAt: Date?
        let configs: [ConfigResponse]?
        let rewards: [RewardResponse]?
        
        struct ConfigResponse: Content {
            let id: UUID?
            let configKey: String
            let configValue: String
        }
        
        struct RewardResponse: Content {
            let id: UUID?
            let rewardType: Int
            let rewardAmount: Int
            let rewardCondition: Int
        }
        
        init(from model: PuzzleLevel, configs: [PuzzleLevelConfig]? = nil, rewards: [PuzzleLevelReward]? = nil) {
            self.id = model.id
            self.levelNumber = model.levelNumber
            self.title = model.title
            self.difficulty = model.difficulty
            self.gridSize = model.gridSize
            self.imageUrl = model.imageUrl
            self.timeLimit = model.timeLimit
            self.movesLimit = model.movesLimit
            self.isPremium = model.isPremium
            self.status = model.status
            self.createdAt = model.createdAt
            self.updatedAt = model.updatedAt
            
            self.configs = configs?.map { config in
                ConfigResponse(
                    id: config.id,
                    configKey: config.configKey,
                    configValue: config.configValue
                )
            }
            
            self.rewards = rewards?.map { reward in
                RewardResponse(
                    id: reward.id,
                    rewardType: reward.rewardType,
                    rewardAmount: reward.rewardAmount,
                    rewardCondition: reward.rewardCondition
                )
            }
        }
    }
}
