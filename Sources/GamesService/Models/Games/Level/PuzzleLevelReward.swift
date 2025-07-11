//
//  PuzzleLevelReward.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 关卡奖励表
final class PuzzleLevelReward: Model, Content, @unchecked Sendable {
    static let schema = "puzzle_level_rewards"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "level_id")
    var level: PuzzleLevel
    
    @Field(key: "reward_type")
    var rewardType: Int
    
    @Field(key: "reward_amount")
    var rewardAmount: Int
    
    @Field(key: "reward_condition")
    var rewardCondition: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        levelID: UUID,
        rewardType: Int,
        rewardAmount: Int,
        rewardCondition: Int
    ) {
        self.id = id
        self.$level.id = levelID
        self.rewardType = rewardType
        self.rewardAmount = rewardAmount
        self.rewardCondition = rewardCondition
    }
}
