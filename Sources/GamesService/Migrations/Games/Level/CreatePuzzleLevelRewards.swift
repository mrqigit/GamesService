//
//  CreatePuzzleLevelRewards.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreatePuzzleLevelRewards: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("puzzle_level_rewards")
            .id()
            .field("level_id", .uuid, .required, .references("puzzle_levels", "id", onDelete: .cascade))
            .field("reward_type", .int, .required)
            .field("reward_amount", .int, .required)
            .field("reward_condition", .int, .required)
            .field("created_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("puzzle_level_rewards").delete()
    }
}
