//
//  CreateConfigRequest.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 创建/更新配置请求
struct CreateConfigRequest: Content, Validatable {
    let cycleType: Int
    let continuousDay: Int
    let rewardType: Int
    let rewardAmount: Int
    let rewardId: UUID?
    let isSpecial: Bool
    let startDate: Date?
    let endDate: Date?
    
    static func validations(_ validations: inout Validations) {
        validations.add("cycleType", as: Int.self)
        validations.add("continuousDay", as: Int.self)
        validations.add("rewardType", as: Int.self)
        validations.add("rewardAmount", as: Int.self)
        validations.add("isSpecial", as: Bool.self)
    }
}

// 配置响应
struct ConfigResponse: Content {
    let id: UUID?
    let cycleType: Int
    let continuousDay: Int
    let rewardType: Int
    let rewardAmount: Int
    let rewardId: UUID?
    let isSpecial: Bool
    let startDate: Date?
    let endDate: Date?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(from model: SignInConfig) {
        self.id = model.id
        self.cycleType = model.cycleType
        self.continuousDay = model.continuousDay
        self.rewardType = model.rewardType
        self.rewardAmount = model.rewardAmount
        self.rewardId = model.rewardId
        self.isSpecial = model.isSpecial
        self.startDate = model.startDate
        self.endDate = model.endDate
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
    }
}
