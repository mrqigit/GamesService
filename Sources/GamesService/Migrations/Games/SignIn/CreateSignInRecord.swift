//
//  CreateSignInRecord.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreateSignInRecord: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("sign_in_record")
            .id()
            .field("user_id", .uuid, .required)
            .field("sign_in_date", .datetime, .required)
            .field("continuous_days", .int, .required)
            .field("reward_status", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .unique(on: "user_id", "sign_in_date") // 防止重复签到
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("sign_in_record").delete()
    }
}
