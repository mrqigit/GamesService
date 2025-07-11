//
//  UserPuzzleProgressDTO.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 用户进度相关DTO
struct UserPuzzleProgressDTO {
    struct Create: Content, Validatable {
        let userID: UUID
        let levelID: UUID
        let isCompleted: Bool
        let bestScore: Int?
        let bestTime: Int?
        let bestMoves: Int?
        let attempts: Int
        
        static func validations(_ validations: inout Validations) {
            validations.add("userID", as: UUID.self)
            validations.add("levelID", as: UUID.self)
            validations.add("isCompleted", as: Bool.self)
            validations.add("attempts", as: Int.self)
        }
    }
    
    struct Response: Content {
        let id: UUID?
        let userID: UUID
        let levelID: UUID
        let isCompleted: Bool
        let bestScore: Int?
        let bestTime: Int?
        let bestMoves: Int?
        let attempts: Int
        let lastAttemptAt: Date?
        let completedAt: Date?
        let createdAt: Date?
        let updatedAt: Date?
        
        init(from model: UserPuzzleProgress) {
            self.id = model.id
            self.userID = model.$user.id
            self.levelID = model.$level.id
            self.isCompleted = model.isCompleted
            self.bestScore = model.bestScore
            self.bestTime = model.bestTime
            self.bestMoves = model.bestMoves
            self.attempts = model.attempts
            self.lastAttemptAt = model.lastAttemptAt
            self.completedAt = model.completedAt
            self.createdAt = model.createdAt
            self.updatedAt = model.updatedAt
        }
    }
}
