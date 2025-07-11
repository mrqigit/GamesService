//
//  SignInConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 签到配置表
final class SignInConfig: Model, Content, @unchecked Sendable {
    static let schema = "sign_in_config"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "cycle_type")
    var cycleType: Int // 0:自然月, 1:固定7天, 2:自定义
    
    @Field(key: "continuous_day")
    var continuousDay: Int
    
    @Field(key: "reward_type")
    var rewardType: Int // 0:虚拟货币, 1:道具, 2:经验值, 3:实物
    
    @Field(key: "reward_amount")
    var rewardAmount: Int
    
    @Field(key: "reward_id")
    var rewardId: UUID?
    
    @Field(key: "is_special")
    var isSpecial: Bool
    
    @Field(key: "start_date")
    var startDate: Date?
    
    @Field(key: "end_date")
    var endDate: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        cycleType: Int,
        continuousDay: Int,
        rewardType: Int,
        rewardAmount: Int,
        rewardId: UUID? = nil,
        isSpecial: Bool,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.id = id
        self.cycleType = cycleType
        self.continuousDay = continuousDay
        self.rewardType = rewardType
        self.rewardAmount = rewardAmount
        self.rewardId = rewardId
        self.isSpecial = isSpecial
        self.startDate = startDate
        self.endDate = endDate
    }
}
