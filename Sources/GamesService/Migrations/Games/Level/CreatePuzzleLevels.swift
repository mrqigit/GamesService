//
//  CreatePuzzleLevels.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreatePuzzleLevels: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("puzzle_levels")
            .id()
            .field("level_number", .int, .required)
            .field("title", .string, .required)
            .field("difficulty", .int, .required)
            .field("grid_size", .string, .required)
            .field("image_url", .string, .required)
            .field("time_limit", .int)
            .field("moves_limit", .int)
            .field("is_premium", .bool, .required)
            .field("status", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .unique(on: "level_number")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("puzzle_levels").delete()
    }
}
