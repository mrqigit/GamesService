//
//  CreateUserPuzzleProgress.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreateUserPuzzleProgress: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user_puzzle_progress")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("level_id", .uuid, .required, .references("puzzle_levels", "id", onDelete: .cascade))
            .field("is_completed", .bool, .required)
            .field("best_score", .int)
            .field("best_time", .int)
            .field("best_moves", .int)
            .field("attempts", .int, .required)
            .field("last_attempt_at", .datetime)
            .field("completed_at", .datetime)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .unique(on: "user_id", "level_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("user_puzzle_progress").delete()
    }
}

