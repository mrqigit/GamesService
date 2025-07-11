//
//  CreateUser.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("role_id", .uuid, .references("roles", "id"))
            .field("avatar_url", .string)
            .field("deleted_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email") // 确保邮箱唯一
            .unique(on: "username") // 确保邮箱唯一
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
