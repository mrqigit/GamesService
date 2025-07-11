//
//  UserPuzzleProgressController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 用户进度控制器
struct UserPuzzleProgressController {
    
    // 创建进度记录
    func create(req: Request) async throws -> UserPuzzleProgressDTO.Response {
        let data = try req.content.decode(UserPuzzleProgressDTO.Create.self)
        
        guard (try await User.query(on: req.db).filter(\.$id == data.userID).first()) != nil else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
        guard (try await PuzzleLevel.query(on: req.db).filter(\.$id == data.levelID).first()) != nil else {
            throw Abort(.notFound, reason: "关卡不存在")
        }
        
        // 检查记录是否已存在
        let existingRecord = try await UserPuzzleProgress.query(on: req.db)
            .filter(\.$user.$id == data.userID)
            .filter(\.$level.$id == data.levelID)
            .first()
        
        if existingRecord != nil {
            throw Abort(.conflict, reason: "用户已有此关卡的进度记录")
        }
        
        let progress = UserPuzzleProgress(
            userID: data.userID,
            levelID: data.levelID,
            isCompleted: data.isCompleted,
            bestScore: data.bestScore,
            bestTime: data.bestTime,
            bestMoves: data.bestMoves,
            attempts: data.attempts
        )
        
        try await progress.save(on: req.db)
        return UserPuzzleProgressDTO.Response(from: progress)
    }
    
    // 获取所有进度记录
    func getAll(req: Request) async throws -> [UserPuzzleProgressDTO.Response] {
        let records = try await UserPuzzleProgress.query(on: req.db)
            .all()
        
        return records.map(UserPuzzleProgressDTO.Response.init)
    }
    
    // 获取单个进度记录
    func show(req: Request) async throws -> UserPuzzleProgressDTO.Response {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的记录ID")
        }
        
        guard let record = try await UserPuzzleProgress.query(on: req.db).filter(\.$id == id).first() else {
            throw Abort(.notFound, reason: "进度记录不存在")
        }
        
        return UserPuzzleProgressDTO.Response(from: record)
    }
    
    // 更新进度记录
    func update(req: Request) async throws -> UserPuzzleProgressDTO.Response {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的记录ID")
        }
        
        guard let record = try await UserPuzzleProgress.query(on: req.db).filter(\.$id == id).first() else {
            throw Abort(.notFound, reason: "进度记录不存在")
        }
        
        let data = try req.content.decode(UserPuzzleProgressDTO.Create.self)
        
        record.isCompleted = data.isCompleted
        record.bestScore = data.bestScore
        record.bestTime = data.bestTime
        record.bestMoves = data.bestMoves
        record.attempts = data.attempts
        
        if data.isCompleted {
            record.completedAt = Date()
        }
        
        record.lastAttemptAt = Date()
        
        try await record.save(on: req.db)
        return UserPuzzleProgressDTO.Response(from: record)
    }
    
    // 删除进度记录
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的记录ID")
        }
        
        guard let record = try await UserPuzzleProgress.query(on: req.db).filter(\.$id == id).first() else {
            throw Abort(.notFound, reason: "进度记录不存在")
        }
        
        try await record.delete(on: req.db)
        return .ok
    }
    
    // 获取用户所有关卡进度
    func getUserProgress(req: Request) async throws -> [UserPuzzleProgressDTO.Response] {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的用户ID")
        }
        
        return try await UserPuzzleProgress.query(on: req.db)
            .filter(\.$user.$id == userID)
            .join(PuzzleLevel.self, on: \UserPuzzleProgress.$level.$id == \PuzzleLevel.$id)
            .sort(PuzzleLevel.self, \.$levelNumber, .ascending)
            .with(\.$level)
            .all().map(UserPuzzleProgressDTO.Response.init)
    }
    
    // 获取关卡所有用户进度
    func getLevelProgress(req: Request) async throws -> [UserPuzzleProgressDTO.Response] {
        guard let levelID = req.parameters.get("levelID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的关卡ID")
        }
        
        let records = try await UserPuzzleProgress.query(on: req.db)
            .filter(\.$level.$id == levelID)
            .all()
        
        return records.map(UserPuzzleProgressDTO.Response.init)
    }
}

