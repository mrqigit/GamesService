//
//  SignInConfigController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor
import FluentKit

struct SignInConfigController {
    
    // 创建签到配置
    func createConfig(req: Request) async throws -> ConfigResponse {
        let request = try req.content.decode(CreateConfigRequest.self)
        
        // 验证连续天数和周期类型组合是否已存在
        let existingConfig = try await SignInConfig.query(on: req.db)
            .filter(\.$cycleType == request.cycleType)
            .filter(\.$continuousDay == request.continuousDay)
            .first()
        
        if existingConfig != nil {
            throw Abort(.conflict, reason: "该周期类型和连续天数的配置已存在")
        }
        
        // 创建新配置
        let config = SignInConfig(
            cycleType: request.cycleType,
            continuousDay: request.continuousDay,
            rewardType: request.rewardType,
            rewardAmount: request.rewardAmount,
            rewardId: request.rewardId,
            isSpecial: request.isSpecial,
            startDate: request.startDate,
            endDate: request.endDate
        )
        
        try await config.save(on: req.db)
        return ConfigResponse(from: config)
    }
    
    // 获取所有配置
    func getAllConfigs(req: Request) async throws -> [ConfigResponse] {
        let configs = try await SignInConfig.query(on: req.db)
            .sort(\.$cycleType, .ascending)
            .sort(\.$continuousDay, .ascending)
            .all()
        
        return configs.map(ConfigResponse.init)
    }
    
    // 获取单个配置
    func getConfig(req: Request) async throws -> ConfigResponse {
        let id: UUID = try req.query.get(UUID.self, at: "id")
        
        guard let config = try await SignInConfig.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "配置不存在")
        }
        
        return ConfigResponse(from: config)
    }
    
    // 更新配置
    func updateConfig(req: Request) async throws -> ConfigResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的配置ID")
        }
        
        guard let config = try await SignInConfig.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "配置不存在")
        }
        
        let updateData = try req.content.decode(CreateConfigRequest.self)
        
        // 更新字段
        config.cycleType = updateData.cycleType
        config.continuousDay = updateData.continuousDay
        config.rewardType = updateData.rewardType
        config.rewardAmount = updateData.rewardAmount
        config.rewardId = updateData.rewardId
        config.isSpecial = updateData.isSpecial
        config.startDate = updateData.startDate
        config.endDate = updateData.endDate
        
        try await config.save(on: req.db)
        return ConfigResponse(from: config)
    }
    
    // 删除配置
    func deleteConfig(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的配置ID")
        }
        
        guard let config = try await SignInConfig.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "配置不存在")
        }
        
        try await config.delete(on: req.db)
        return .ok
    }
}
