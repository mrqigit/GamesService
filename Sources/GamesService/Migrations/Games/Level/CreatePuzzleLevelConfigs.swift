//
//  CreatePuzzleLevelConfigs.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreatePuzzleLevelConfigs: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("puzzle_level_configs")
            .id()
            .field("level_id", .uuid, .required, .references("puzzle_levels", "id", onDelete: .cascade))
            .field("config_key", .string, .required)
            .field("config_value", .string, .required)
            .field("created_at", .datetime, .required)
            .unique(on: "level_id", "config_key")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("puzzle_level_configs").delete()
    }
}
