//
//  PuzzleLevelController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 关卡控制器
struct PuzzleLevelController {
    
    // 创建关卡
    func create(req: Request) async throws -> PuzzleLevelDTO.Response {
        let data = try req.content.decode(PuzzleLevelDTO.Create.self)
        
        // 检查关卡序号是否已存在
        let existingLevel = try await PuzzleLevel.query(on: req.db)
            .filter(\.$levelNumber == data.levelNumber)
            .first()
        
        if existingLevel != nil {
            throw Abort(.conflict, reason: "关卡序号已存在")
        }
        
        let level = PuzzleLevel(
            levelNumber: data.levelNumber,
            title: data.title,
            difficulty: data.difficulty,
            gridSize: data.gridSize,
            imageUrl: data.imageUrl,
            timeLimit: data.timeLimit,
            movesLimit: data.movesLimit,
            isPremium: data.isPremium,
            status: data.status
        )
        
        try await level.save(on: req.db)
        
        // 关联查询配置和奖励
        let configs = try await level.$configs.query(on: req.db).all()
        let rewards = try await level.$rewards.query(on: req.db).all()
        
        return PuzzleLevelDTO.Response(from: level, configs: configs, rewards: rewards)
    }
    
    // 获取所有关卡
    func getAll(req: Request) async throws -> Page<PuzzleLevelDTO.Response> {
        let pageRequest = try req.query.decode(PageRequest.self)
        return try await PuzzleLevel.query(on: req.db)
            .sort(\.$levelNumber, .ascending)
            .with(\.$configs)
            .with(\.$rewards)
            .paginate(pageRequest).map { level in
                return PuzzleLevelDTO.Response(from: level, configs: level.configs, rewards: level.rewards)
            }
    }
    
    // 获取单个关卡
    func show(req: Request) async throws -> PuzzleLevelDTO.Response {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        guard let level = try await PuzzleLevel.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$configs)
            .with(\.$rewards).first() else {
            throw Abort(.notFound, reason: "关卡不存在")
        }
        
        return PuzzleLevelDTO.Response(from: level, configs: level.configs, rewards: level.rewards)
    }
    
    // 更新关卡
    func update(req: Request) async throws -> PuzzleLevelDTO.Response {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        guard let level = try await PuzzleLevel.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$configs)
            .with(\.$rewards).first() else {
            throw Abort(.notFound, reason: "关卡不存在")
        }
        
        let data = try req.content.decode(PuzzleLevelDTO.Create.self)
        
        // 检查新的关卡序号是否已被其他关卡使用
        if level.levelNumber != data.levelNumber {
            let existingLevel = try await PuzzleLevel.query(on: req.db)
                .filter(\.$levelNumber == data.levelNumber)
                .first()
            
            if existingLevel != nil {
                throw Abort(.conflict, reason: "关卡序号已被其他关卡使用")
            }
        }
        
        level.levelNumber = data.levelNumber
        level.title = data.title
        level.difficulty = data.difficulty
        level.gridSize = data.gridSize
        level.imageUrl = data.imageUrl
        level.timeLimit = data.timeLimit
        level.movesLimit = data.movesLimit
        level.isPremium = data.isPremium
        level.status = data.status
        
        try await level.save(on: req.db)
        
        let configs = try await level.$configs.query(on: req.db).all()
        let rewards = try await level.$rewards.query(on: req.db).all()
        
        return PuzzleLevelDTO.Response(from: level, configs: configs, rewards: rewards)
    }
    
    // 删除关卡
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        guard let level = try await PuzzleLevel.query(on: req.db)
            .filter(\.$id == id).first() else {
            throw Abort(.notFound, reason: "关卡不存在")
        }
        
        try await level.delete(on: req.db)
        return .ok
    }
    
    // 创建关卡配置
    func createConfig(req: Request) async throws -> PuzzleLevelConfigDTO.Response {
        guard let levelID = req.parameters.get("levelID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        // 验证关卡是否存在
        guard (try await PuzzleLevel.query(on: req.db)
            .filter(\.$id == levelID).first()) != nil else {
            throw Abort(.notFound, reason: "关卡不存在")
        }
        
        let data = try req.content.decode(PuzzleLevelConfigDTO.Create.self)
        
        // 检查配置键是否已存在
        let existingConfig = try await PuzzleLevelConfig.query(on: req.db)
            .filter(\.$level.$id == levelID)
            .filter(\.$configKey == data.configKey)
            .first()
        
        if existingConfig != nil {
            throw Abort(.conflict, reason: "该配置键已存在")
        }
        
        let config = PuzzleLevelConfig(
            levelID: levelID,
            configKey: data.configKey,
            configValue: data.configValue
        )
        
        try await config.save(on: req.db)
        return PuzzleLevelConfigDTO.Response(from: config)
    }
    
    // 获取关卡所有配置
    func getConfigs(req: Request) async throws -> [PuzzleLevelConfigDTO.Response] {
        guard let levelID = req.parameters.get("levelID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        let configs = try await PuzzleLevelConfig.query(on: req.db)
            .filter(\.$level.$id == levelID)
            .all()
        
        return configs.map(PuzzleLevelConfigDTO.Response.init)
    }
    
    // 创建关卡奖励
    func createReward(req: Request) async throws -> PuzzleLevelRewardDTO.Response {
        guard let levelID = req.parameters.get("levelID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        // 验证关卡是否存在
        guard (try await PuzzleLevel.query(on: req.db)
            .filter(\.$id == levelID).first()) != nil else {
            throw Abort(.notFound, reason: "关卡不存在")
        }
        
        let data = try req.content.decode(PuzzleLevelRewardDTO.Create.self)
        
        let reward = PuzzleLevelReward(
            levelID: levelID,
            rewardType: data.rewardType,
            rewardAmount: data.rewardAmount,
            rewardCondition: data.rewardCondition
        )
        
        try await reward.save(on: req.db)
        return PuzzleLevelRewardDTO.Response(from: reward)
    }
    
    // 获取关卡所有奖励
    func getRewards(req: Request) async throws -> [PuzzleLevelRewardDTO.Response] {
        guard let levelID = req.parameters.get("levelID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        let rewards = try await PuzzleLevelReward.query(on: req.db)
            .filter(\.$level.$id == levelID)
            .all()
        
        return rewards.map(PuzzleLevelRewardDTO.Response.init)
    }
}
