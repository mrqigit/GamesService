//
//  RoleController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/7.
//

import Vapor
import FluentKit

struct RoleController {
    
    // 获取所有角色（分页+过滤软删除）
    func index(req: Request) async throws -> Page<RoleResponse> {
        // 使用可选获取方法：参数不存在时返回 nil，而非抛出错误
        let page = try? req.query.get(Int.self, at: "page")
        let perPage = try? req.query.get(Int.self, at: "perPage")
           
        // 确保 page 和 perPage 不为 nil（兜底默认值）
        let safePage = page ?? 1
        let safePerPage = perPage ?? 10
        
        let pageRequest = PageRequest(page: safePage, per: safePerPage)
        
        return try await Role.query(on: req.db)
            .filter(\Role.$deletedAt == nil)
            .sort(\.$createdAt, .descending)
            .paginate(pageRequest).map { role in
                RoleResponse(from: role)
            }
    }
    
    // 获取单个角色（过滤软删除）
    func show(req: Request) async throws -> RoleResponse {
        // 1. 获取并转换 ID 参数
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString)
        else {
            throw Abort(.badRequest, reason: ErrorMessage.invalidID)
        }
            
        // 2. 用转换后的 UUID 过滤
        guard let role = try await Role.query(on: req.db)
            .filter(\.$id == id)  // 现在两边都是 UUID 类型
            .filter(\.$deletedAt == nil)
            .first()
        else {
            throw Abort(.badRequest, reason: ErrorMessage.roleNotFound)
        }
            
        return RoleResponse(from: role)
    }
    
    // 创建角色（验证唯一性和非空）
    func create(req: Request) async throws -> RoleResponse {
        // 1. 验证并解析请求
        let createRequest = try req.content.decode(CreateRoleRequest.self)
                
        // 2. 从 DTO 创建模型
        let role = Role(
            type: createRequest.type,
            typeZh: createRequest.typeZh,
            typeEn: createRequest.typeEn
        )
        
        // 非空验证
        guard !role.type.isEmpty, !role.typeZh.isEmpty, !role.typeEn.isEmpty else {
            throw Abort(.badRequest, reason: ErrorMessage.emptyFields)
        }
        
        // 唯一性验证（排除已删除角色）
        let exists = try await Role.query(on: req.db)
            .filter(\.$type == role.type)
            .filter(\.$deletedAt == nil)
            .count() > 0
        
        if exists {
            throw Abort(.badRequest, reason: ErrorMessage.alreadyExists)
        }
        
        try await role.save(on: req.db)
        return RoleResponse(from: role)
    }
    
    // 更新角色
    func update(req: Request) async throws -> RoleResponse {
        // 1. 将请求参数的 String ID 转换为 UUID
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString)
        else {
            throw Abort(.badRequest, reason: ErrorMessage.invalidID)
        }
        
        // 2. 用 UUID 过滤角色（类型匹配）
        guard let role = try await Role.query(on: req.db)
            .filter(\.$id == id)  // 左侧是 UUID 键路径，右侧是 UUID 类型
            .filter(\.$deletedAt == nil)
            .first()
        else {
            throw Abort(.badRequest, reason: ErrorMessage.roleNotFound)
        }
        
        // 3. 解析更新数据并验证
        let updateRequest = try req.content.decode(UpdateRoleRequest.self)
        
        // 非空验证
        guard updateRequest.type.isNotEmpty, updateRequest.typeZh.isNotEmpty, updateRequest.typeEn.isNotEmpty else {
            throw Abort(.badRequest, reason: ErrorMessage.emptyFields)
        }
        
        // 4. 验证 type 唯一性（若修改）
        if role.type != updateRequest.type {
            let exists = try await Role.query(on: req.db)
                .filter(\.$type == updateRequest.type ?? "")
                .filter(\.$deletedAt == nil)
                .count() > 0
            
            if exists {
                throw Abort(.badRequest, reason: ErrorMessage.alreadyExists)
            }
            role.type = updateRequest.type ?? ""
        }
        
        // 5. 更新其他字段
        role.typeZh = updateRequest.typeZh ?? ""
        role.typeEn = updateRequest.typeEn ?? ""
        
        try await role.update(on: req.db)
        return RoleResponse(from: role)
    }
    
    // 软删除角色
    func delete(req: Request) async throws -> HTTPStatus {
        // 1. 转换 ID 类型
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString)
        else {
            throw Abort(.badRequest, reason: ErrorMessage.invalidID)
        }
        
        // 2. 用 UUID 过滤角色
        guard let role = try await Role.query(on: req.db)
            .filter(\.$id == id)  // 类型匹配
            .filter(\.$deletedAt == nil)
            .first()
        else {
            throw Abort(.badRequest, reason: ErrorMessage.roleNotFound)
        }
        
        // 3. 执行软删除
        try await role.delete(on: req.db)  // 自动设置 deletedAt 时间戳
        return .ok
    }
    
    // 恢复删除
    func restore(req: Request) async throws -> RoleResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的ID")
        }
            
        // 查找已删除的记录
        guard let role = try await Role.query(on: req.db)
            .filter(\.$deletedAt != nil)
            .filter(\Role.$id == id)
            .filter(\Role.$deletedAt != nil)
            .first() else {
            throw Abort(.notFound, reason: "未找到已删除的记录")
        }
            
        // 恢复记录（设置deletedAt为nil）
        role.deletedAt = nil
        try await role.save(on: req.db)
            
        return RoleResponse(from: role)
    }
}

// 定义错误信息常量
private enum ErrorMessage {
    static let invalidID = "无效的角色 ID（格式错误）"
    static let roleNotFound = "角色不存在"
    static let emptyFields = "角色类型及翻译不能为空"
    static let alreadyExists = "角色类型已存在"
}
