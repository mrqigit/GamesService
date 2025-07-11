//
//  CreateSignInConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreateSignInConfig: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("sign_in_config")
            .id()
            .field("cycle_type", .int, .required)
            .field("continuous_day", .int, .required)
            .field("reward_type", .int, .required)
            .field("reward_amount", .int, .required)
            .field("reward_id", .uuid)
            .field("is_special", .bool, .required)
            .field("start_date", .datetime)
            .field("end_date", .datetime)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("sign_in_config").delete()
    }
}
