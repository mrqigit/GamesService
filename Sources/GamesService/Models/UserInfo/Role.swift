//
//  Role.swift
//  GamesService
//
//  Created by MrQi on 2025/7/7.
//

import Fluent
import Vapor

final class Role: Model, Content, @unchecked Sendable {
    
    static let schema = "roles"
        
    @ID(key: .id)
    var id: UUID?
        
    @Field(key: "type")
    var type: String  // 角色类型（如 "admin"）
        
    @Field(key: "type_zh")
    var typeZh: String  // 中文翻译
        
    @Field(key: "type_en")
    var typeEn: String  // 英文翻译
        
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
        
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
        
    init() { }
        
    init(id: UUID? = nil, type: String, typeZh: String, typeEn: String) {
        self.id = id
        self.type = type
        self.typeZh = typeZh
        self.typeEn = typeEn
    }
}
