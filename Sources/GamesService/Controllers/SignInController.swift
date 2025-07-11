//
//  SignInController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor
import FluentKit

struct SignInController {
    
    // 签到接口
    func signIn(req: Request) async throws -> SignInResponse {
        let request = try req.content.decode(SignInRequest.self)
        let userId = request.userId
        let today = Date().startOfDay() // 需要实现 Date 扩展
        
        // 检查今日是否已签到
        let existingRecord = try await SignInRecord.query(on: req.db)
            .filter(\.$userId == userId)
            .filter(\.$signInDate == today)
            .first()
        
        if existingRecord != nil {
            throw Abort(.conflict, reason: "今日已签到")
        }
        
        // 计算连续签到天数
        let yesterday = today.addingTimeInterval(-86400)
        let prevRecord = try await SignInRecord.query(on: req.db)
            .filter(\.$userId == userId)
            .filter(\.$signInDate == yesterday)
            .first()
        
        let continuousDays = prevRecord?.continuousDays ?? 0 + 1
        
        // 创建签到记录
        let newRecord = SignInRecord(
            userId: userId,
            signInDate: today,
            continuousDays: continuousDays,
            rewardStatus: 0 // 未领取奖励
        )
        
        try await newRecord.save(on: req.db)
        
        // 获取对应奖励配置
        let rewardConfig = try await getRewardConfig(for: continuousDays, on: req.db)
        
        return SignInResponse(
            success: true,
            message: "签到成功",
            continuousDays: continuousDays,
            reward: rewardConfig.map {
                SignInResponse.RewardInfo(
                    rewardType: $0.rewardType,
                    rewardAmount: $0.rewardAmount,
                    rewardId: $0.rewardId
                )
            }
        )
    }
    
    // 获取签到状态
    func getSignInStatus(req: Request) async throws -> SignInStatusResponse {
        guard let userId = req.auth.get(User.self)?.id else {
            throw Abort(.unauthorized)
        }
        
        let today = Date().startOfDay()
        
        // 检查今日是否已签到
        let todayRecord = try await SignInRecord.query(on: req.db)
            .filter(\.$userId == userId)
            .filter(\.$signInDate == today)
            .first()
        
        // 获取当前连续签到天数
        let currentStreak = todayRecord?.continuousDays ?? 0
        
        // 获取本月总签到次数
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let totalSignIns = try await SignInRecord.query(on: req.db)
            .filter(\.$userId == userId)
            .filter(\.$signInDate >= startOfMonth)
            .filter(\.$signInDate <= today)
            .count()
        
        // 获取可用奖励
        let todayRewardClaimed = todayRecord?.rewardStatus == 1
        
        // 获取当前周期所有奖励配置
        let configs = try await SignInConfig.query(on: req.db)
            .filter(\.$cycleType == 0) // 自然月
            .group(.or) { group in
                group.filter(\.$endDate >= today)
                group.filter(\.$endDate == nil)
            }
            .sort(\.$continuousDay, .ascending)
            .all()
        
        // 获取用户已领取奖励记录
        let claimedRewards = try await SignInRewardLog.query(on: req.db)
            .filter(\.$userId == userId)
            .all()
        
        let availableRewards = configs.map { config in
            let claimed = claimedRewards.contains { $0.configId == config.id }
            return SignInStatusResponse.RewardInfo(
                day: config.continuousDay,
                rewardType: config.rewardType,
                rewardAmount: config.rewardAmount,
                isSpecial: config.isSpecial,
                claimed: claimed
            )
        }
        
        return SignInStatusResponse(
            hasSigned: todayRecord != nil,
            currentStreak: currentStreak,
            totalSignIns: totalSignIns,
            todayRewardClaimed: todayRewardClaimed,
            availableRewards: availableRewards
        )
    }
    
    // 领取奖励
    func claimReward(req: Request) async throws -> ClaimRewardResponse {
        guard let userId = req.auth.get(User.self)?.id else {
            throw Abort(.unauthorized)
        }
        
        let today = Date().startOfDay()
        
        // 检查今日是否已签到
        guard let signRecord = try await SignInRecord.query(on: req.db)
            .filter(\.$userId == userId)
            .filter(\.$signInDate == today)
            .first() else {
            throw Abort(.notFound, reason: "今日未签到，无法领取奖励")
        }
        
        // 检查奖励是否已领取
        if signRecord.rewardStatus == 1 {
            throw Abort(.conflict, reason: "奖励已领取")
        }
        
        // 获取对应奖励配置
        guard let rewardConfig = try await getRewardConfig(for: signRecord.continuousDays, on: req.db) else {
            throw Abort(.notFound, reason: "未找到对应奖励配置")
        }
        
        // 发放奖励（这里需要调用实际的奖励发放逻辑）
        do {
            // 模拟奖励发放
            try await distributeReward(
                userId: userId,
                rewardType: rewardConfig.rewardType,
                amount: rewardConfig.rewardAmount,
                rewardId: rewardConfig.rewardId,
                db: req.db
            )
            
            // 更新签到记录状态
            signRecord.rewardStatus = 1
            try await signRecord.save(on: req.db)
            
            // 记录奖励发放日志
            let rewardLog = SignInRewardLog(
                userId: userId,
                signInRecordId: signRecord.id!,
                configId: rewardConfig.id!,
                rewardType: rewardConfig.rewardType,
                rewardAmount: rewardConfig.rewardAmount,
                status: 1, // 已发放
                issuedAt: Date()
            )
            
            try await rewardLog.save(on: req.db)
            
            return ClaimRewardResponse(
                success: true,
                message: "奖励领取成功",
                reward: ClaimRewardResponse.RewardInfo(
                    rewardType: rewardConfig.rewardType,
                    rewardAmount: rewardConfig.rewardAmount,
                    rewardId: rewardConfig.rewardId
                )
            )
        } catch {
            // 记录发放失败日志
            let failureLog = SignInRewardLog(
                userId: userId,
                signInRecordId: signRecord.id!,
                configId: rewardConfig.id!,
                rewardType: rewardConfig.rewardType,
                rewardAmount: rewardConfig.rewardAmount,
                status: 2, // 发放失败
                failureReason: error.localizedDescription
            )
            
            try await failureLog.save(on: req.db)
            
            throw Abort(.internalServerError, reason: "奖励发放失败: \(error.localizedDescription)")
        }
    }
    
    // 获取对应连续天数的奖励配置
    private func getRewardConfig(for continuousDays: Int, on db: any Database) async throws -> SignInConfig? {
        let today = Date()
        
        return try await SignInConfig.query(on: db)
            .filter(\.$continuousDay == continuousDays)
            .group(.or) { group in
                group.filter(\.$endDate >= today)
                group.filter(\.$endDate == nil)
            }
            .first()
    }
    
    // 奖励发放逻辑（需要根据实际游戏系统实现）
    private func distributeReward(userId: UUID, rewardType: Int, amount: Int, rewardId: UUID?, db: any Database) async throws {
        // 这里需要实现实际的奖励发放逻辑
        // 例如：调用道具系统、货币系统等接口
        // 此为示例实现，需根据实际游戏系统调整
        switch rewardType {
        case 0: // 虚拟货币
            // 调用货币系统增加用户货币
            break
        case 1: // 道具
            // 调用道具系统添加道具到用户背包
            break
        case 2: // 经验值
            // 调用经验系统增加用户经验
            break
        case 3: // 实物
            // 记录实物奖励，等待人工处理
            break
        default:
            throw Abort(.internalServerError, reason: "未知奖励类型")
        }
    }
}
