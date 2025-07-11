//
//  SignInRequest.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

// 签到请求
struct SignInRequest: Content, Validatable {
    let userId: UUID
    
    static func validations(_ validations: inout Validations) {
        validations.add("userId", as: UUID.self)
    }
}

// 签到响应
struct SignInResponse: Content {
    let success: Bool
    let message: String
    let continuousDays: Int
    let reward: RewardInfo?
    
    struct RewardInfo: Content {
        let rewardType: Int
        let rewardAmount: Int
        let rewardId: UUID?
    }
}

// 签到状态响应
struct SignInStatusResponse: Content {
    let hasSigned: Bool
    let currentStreak: Int
    let totalSignIns: Int
    let todayRewardClaimed: Bool
    let availableRewards: [RewardInfo]
    
    struct RewardInfo: Content {
        let day: Int
        let rewardType: Int
        let rewardAmount: Int
        let isSpecial: Bool
        let claimed: Bool
    }
}

// 奖励领取响应
struct ClaimRewardResponse: Content {
    let success: Bool
    let message: String
    let reward: RewardInfo?
    
    struct RewardInfo: Content {
        let rewardType: Int
        let rewardAmount: Int
        let rewardId: UUID?
    }
}
