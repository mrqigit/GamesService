//
//  CreateRoles.swift
//  GamesService
//
//  Created by MrQi on 2025/7/8.
//

import Fluent

struct CreateRoles: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // 1. 创建表结构
        try await database.schema("roles")
            .field("id", .uuid, .identifier(auto: true))
            .field("type", .string, .required)
            .field("type_zh", .string, .required)
            .field("type_en", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "type")
            .create()
                
        // 2. 插入默认数据
        try await [
            Role(
                type: "admin",
                typeZh: "管理员",
                typeEn: "Administrator"
            ),
            Role(
                type: "user",
                typeZh: "普通用户",
                typeEn: "User"
            ),
            Role(
                type: "guest",
                typeZh: "访客",
                typeEn: "Guest"
            )
        ].create(on: database)
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("roles").delete()
    }
}
