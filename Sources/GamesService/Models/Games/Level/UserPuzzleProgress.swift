//
//  UserPuzzleProgress.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 用户关卡进度表
final class UserPuzzleProgress: Model, Content, @unchecked Sendable {
    static let schema = "user_puzzle_progress"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "level_id")
    var level: PuzzleLevel
    
    @Field(key: "is_completed")
    var isCompleted: Bool
    
    @Field(key: "best_score")
    var bestScore: Int?
    
    @Field(key: "best_time")
    var bestTime: Int?
    
    @Field(key: "best_moves")
    var bestMoves: Int?
    
    @Field(key: "attempts")
    var attempts: Int
    
    @Field(key: "last_attempt_at")
    var lastAttemptAt: Date?
    
    @Field(key: "completed_at")
    var completedAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        userID: UUID,
        levelID: UUID,
        isCompleted: Bool = false,
        bestScore: Int? = nil,
        bestTime: Int? = nil,
        bestMoves: Int? = nil,
        attempts: Int = 0,
        lastAttemptAt: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.$user.id = userID
        self.$level.id = levelID
        self.isCompleted = isCompleted
        self.bestScore = bestScore
        self.bestTime = bestTime
        self.bestMoves = bestMoves
        self.attempts = attempts
        self.lastAttemptAt = lastAttemptAt
        self.completedAt = completedAt
    }
}
