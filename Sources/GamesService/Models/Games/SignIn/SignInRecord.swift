//
//  SignInRecord.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 签到记录表
final class SignInRecord: Model, Content, @unchecked Sendable {
    static let schema = "sign_in_record"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID
    
    @Field(key: "sign_in_date")
    var signInDate: Date
    
    @Field(key: "continuous_days")
    var continuousDays: Int
    
    @Field(key: "reward_status")
    var rewardStatus: Int // 0:未领取, 1:已领取
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        userId: UUID,
        signInDate: Date,
        continuousDays: Int,
        rewardStatus: Int
    ) {
        self.id = id
        self.userId = userId
        self.signInDate = signInDate
        self.continuousDays = continuousDays
        self.rewardStatus = rewardStatus
    }
}
