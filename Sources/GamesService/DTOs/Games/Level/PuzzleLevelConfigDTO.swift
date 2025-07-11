//
//  PuzzleLevelConfigDTO.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 关卡配置相关DTO
struct PuzzleLevelConfigDTO {
    struct Create: Content, Validatable {
        let levelID: UUID
        let configKey: String
        let configValue: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("levelID", as: UUID.self)
            validations.add("configKey", as: String.self)
            validations.add("configValue", as: String.self)
        }
    }
    
    struct Response: Content {
        let id: UUID?
        let levelID: UUID
        let configKey: String
        let configValue: String
        let createdAt: Date?
        
        init(from model: PuzzleLevelConfig) {
            self.id = model.id
            self.levelID = model.$level.id
            self.configKey = model.configKey
            self.configValue = model.configValue
            self.createdAt = model.createdAt
        }
    }
}
