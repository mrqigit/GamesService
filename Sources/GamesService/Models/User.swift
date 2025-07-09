//
//  User.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent
import Vapor

final class User: Model, Content, ModelAuthenticatable, @unchecked Sendable {
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Parent(key: "role_id")
    var role: Role
    
    @Field(key: "avatar_url")
    var avatarUrl: String?
    
    @Field(key: "deleted_at")
    var deletedAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // 与实名认证表的一对一关联
    @OptionalChild(for: \.$user)
    var realNameAuth: RealNameAuth?
    
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash
        
    func verify(password: String) throws -> Bool {
        // ✅ 使用 Bcrypt 验证密码
        return try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    init() {}
    
    init(
        id: UUID? = nil,
        username: String,
        email: String,
        passwordHash: String,
        roleId: UUID,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.$role.id = roleId
        self.avatarUrl = avatarUrl
    }
}
