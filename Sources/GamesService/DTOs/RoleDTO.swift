//
//  RoleRequest.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor

/// 1. 创建角色请求 DTO
struct CreateRoleRequest: Content, Validatable {
    let type: String
    let typeZh: String
    let typeEn: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("type", as: String.self, is: .count(1...50))
        validations.add("typeZh", as: String.self, is: .count(1...50))
        validations.add("typeEn", as: String.self, is: .count(1...50))
        
        // 可选：限制角色类型范围
        let allowedTypes = ["admin", "user", "editor", "guest"]
        validations.add("type", as: String.self, is: .in(allowedTypes))
    }
}

/// 2. 更新角色请求 DTO（使用可选字段，允许部分更新）
struct UpdateRoleRequest: Content, Validatable {
    let type: String?
    let typeZh: String?
    let typeEn: String?
    
    static func validations(_ validations: inout Validations) {
        validations.add("type", as: String?.self, is: .nil || .count(1...50))
        validations.add("typeZh", as: String?.self, is: .nil || .count(1...50))
        validations.add("typeEn", as: String?.self, is: .nil || .count(1...50))
    }
}

/// 3. 角色响应 DTO（可选择性暴露字段，如隐藏敏感信息）
struct RoleResponse: Content {
    let id: UUID
    let type: String
    let typeZh: String
    let typeEn: String
    let createdAt: Date?
    let updatedAt: Date?
    
    // 从模型初始化响应 DTO
    init(from model: Role) {
        self.id = model.id!
        self.type = model.type
        self.typeZh = model.typeZh
        self.typeEn = model.typeEn
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
    }
}
