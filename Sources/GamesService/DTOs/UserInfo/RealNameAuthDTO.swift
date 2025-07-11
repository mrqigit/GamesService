//
//  RealNameAuthDTO.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent
import Vapor

// 创建实名认证请求DTO
struct CreateRealNameAuthRequest: Content {
    let userId: UUID
    let realName: String
    let idCard: String
    let idCardFrontUrl: String?
    let idCardBackUrl: String?
}

// 实名认证响应DTO（隐藏敏感字段）
struct RealNameAuthResponse: Content {
    let id: UUID?
    let userId: UUID?
    let realName: String?
    let status: Int?
    let rejectReason: String?
    let createdAt: Date?
    let updatedAt: Date?
    let verifiedAt: Date?
    
    init(from model: RealNameAuth?) {
        self.id = model?.id
        self.userId = model?.$user.id
        self.realName = model?.realName
        self.status = model?.status
        self.rejectReason = model?.rejectReason
        self.createdAt = model?.createdAt
        self.updatedAt = model?.updatedAt
        self.verifiedAt = model?.verifiedAt
    }
}

// 审核请求DTO
struct VerifyRealNameAuthRequest: Content {
    let status: Int
    let reason: String?
    
    // 验证状态是否有效
    func isValidStatus() -> Bool {
        return status == 1 || status == 2 // 1: 通过，2: 拒绝
    }
}
