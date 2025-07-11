//
//  CreateSignInRewardLog.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent

struct CreateSignInRewardLog: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("sign_in_reward_log")
            .id()
            .field("user_id", .uuid, .required)
            .field("sign_in_record_id", .uuid, .required)
            .field("config_id", .uuid, .required)
            .field("reward_type", .int, .required)
            .field("reward_amount", .int, .required)
            .field("status", .int, .required)
            .field("issued_at", .datetime)
            .field("failure_reason", .string)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("sign_in_reward_log").delete()
    }
}
