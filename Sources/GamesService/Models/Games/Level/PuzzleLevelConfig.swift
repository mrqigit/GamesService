//
//  PuzzleLevelConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 关卡配置表
final class PuzzleLevelConfig: Model, Content, @unchecked Sendable {
    static let schema = "puzzle_level_configs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "level_id")
    var level: PuzzleLevel
    
    @Field(key: "config_key")
    var configKey: String
    
    @Field(key: "config_value")
    var configValue: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        levelID: UUID,
        configKey: String,
        configValue: String
    ) {
        self.id = id
        self.$level.id = levelID
        self.configKey = configKey
        self.configValue = configValue
    }
}
