//
//  UserDTO.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent
import Vapor

// 创建用户请求DTO
struct CreateUserRequest: Content {
    let username: String
    let email: String
    let password: String
    let roleId: UUID?
    
    // 验证方法
    func validate() throws {
        guard username.count >= 3 else {
            throw Abort(.badRequest, reason: "用户名长度至少为3个字符")
        }
        
        guard email.contains("@") && email.contains(".") else {
            throw Abort(.badRequest, reason: "邮箱格式不正确")
        }
        
        guard password.count >= 8 else {
            throw Abort(.badRequest, reason: "密码长度至少为8个字符")
        }
    }
}

// 用户响应DTO（包含关联数据）
struct UserResponse: Content {
    let id: UUID?
    let username: String
    let email: String
    let role: RoleResponse
    let avatarUrl: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let realNameAuth: RealNameAuthResponse?
    
    init(from model: User, role: RoleResponse, auth: RealNameAuthResponse? = nil) {
        self.id = model.id
        self.username = model.username
        self.email = model.email
        self.role = role
        self.avatarUrl = model.avatarUrl
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
        self.deletedAt = model.deletedAt
        
        if let auth = auth {
            self.realNameAuth = auth
        } else {
            self.realNameAuth = nil
        }
    }
}

// 更新用户请求DTO
struct UpdateUserRequest: Content {
    let username: String?
    let email: String?
    let roleId: UUID?
    let avatarUrl: String?
}

// 登录请求DTO
struct LoginRequest: Content {
    let username: String
    let password: String
}

// 登录响应DTO
struct LoginResponse: Content {
    let token: String
    let user: UserResponse
}
