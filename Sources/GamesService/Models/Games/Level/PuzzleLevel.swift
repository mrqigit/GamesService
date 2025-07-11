//
//  PuzzleLevel.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 拼图关卡表
final class PuzzleLevel: Model, Content, @unchecked Sendable {
    static let schema = "puzzle_levels"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "level_number")
    var levelNumber: Int
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "difficulty")
    var difficulty: Int
    
    @Field(key: "grid_size")
    var gridSize: String
    
    @Field(key: "image_url")
    var imageUrl: String
    
    @Field(key: "time_limit")
    var timeLimit: Int?
    
    @Field(key: "moves_limit")
    var movesLimit: Int?
    
    @Field(key: "is_premium")
    var isPremium: Bool
    
    @Field(key: "status")
    var status: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$level)
    var configs: [PuzzleLevelConfig]
    
    @Children(for: \.$level)
    var rewards: [PuzzleLevelReward]
    
    @Siblings(through: UserPuzzleProgress.self, from: \.$level, to: \.$user)
    var users: [User]
    
    init() { }
    
    init(
        id: UUID? = nil,
        levelNumber: Int,
        title: String,
        difficulty: Int,
        gridSize: String,
        imageUrl: String,
        timeLimit: Int? = nil,
        movesLimit: Int? = nil,
        isPremium: Bool,
        status: Int
    ) {
        self.id = id
        self.levelNumber = levelNumber
        self.title = title
        self.difficulty = difficulty
        self.gridSize = gridSize
        self.imageUrl = imageUrl
        self.timeLimit = timeLimit
        self.movesLimit = movesLimit
        self.isPremium = isPremium
        self.status = status
    }
}
