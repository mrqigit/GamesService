//
//  SignInRewardLog.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 奖励发放记录表
final class SignInRewardLog: Model, Content, @unchecked Sendable {
    static let schema = "sign_in_reward_log"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID
    
    @Field(key: "sign_in_record_id")
    var signInRecordId: UUID
    
    @Field(key: "config_id")
    var configId: UUID
    
    @Field(key: "reward_type")
    var rewardType: Int
    
    @Field(key: "reward_amount")
    var rewardAmount: Int
    
    @Field(key: "status")
    var status: Int // 0:待发放, 1:已发放, 2:发放失败
    
    @Field(key: "issued_at")
    var issuedAt: Date?
    
    @Field(key: "failure_reason")
    var failureReason: String?
    
    init() { }
    
    init(
        id: UUID? = nil,
        userId: UUID,
        signInRecordId: UUID,
        configId: UUID,
        rewardType: Int,
        rewardAmount: Int,
        status: Int,
        issuedAt: Date? = nil,
        failureReason: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.signInRecordId = signInRecordId
        self.configId = configId
        self.rewardType = rewardType
        self.rewardAmount = rewardAmount
        self.status = status
        self.issuedAt = issuedAt
        self.failureReason = failureReason
    }
}
