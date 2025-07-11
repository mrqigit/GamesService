//
//  CreateUserVerification.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent

struct CreateRealNameAuth: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("real_name_auths")
            .id()
            .field("user_id", .uuid, .required)
            .field("real_name", .string, .required)
            .field("id_card", .string, .required)
            .field("id_card_front_url", .string)
            .field("id_card_back_url", .string)
            .field("status", .int, .required)
            .field("reject_reason", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("verified_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "user_id")
            .unique(on: "id_card")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("real_name_auths").delete()
    }
}
