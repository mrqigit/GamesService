//
//  CreateAdvertisements.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreateAdvertisements: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("advertisements")
            .id()
            .field("title", .string, .required)
            .field("image_url", .string, .required)
            .field("link_url", .string, .required)
            .field("position", .string, .required)
            .field("start_date", .datetime, .required)
            .field("end_date", .datetime, .required)
            .field("source", .string, .required)
            .field("status", .string, .required)
            .field("sort_order", .int, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("advertisements").delete()
    }
}
