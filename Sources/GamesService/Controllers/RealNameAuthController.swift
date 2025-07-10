//
//  RealNameAuthController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Vapor
import FluentKit

struct RealNameAuthController {
    
    func index(req: Request) async throws -> Page<RealNameAuthResponse> {
        // 使用可选获取方法：参数不存在时返回 nil，而非抛出错误
        let pageRequest = try req.query.decode(PageRequest.self)
        
        return try await RealNameAuth.query(on: req.db)
            .filter(\.$deletedAt == nil)
            .sort(\.$createdAt, .descending)
            .paginate(pageRequest).map { realNameAuth in
                RealNameAuthResponse(from: realNameAuth)
            }
    }
    
    func show(req: Request) async throws -> RealNameAuthResponse {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的用户ID")
        }
            
        guard let auth = try await RealNameAuth.query(on: req.db)
            .filter(\RealNameAuth.$user.$id == userId)
            .first() else {
            throw Abort(.notFound, reason: "未找到认证记录")
        }
            
        return RealNameAuthResponse(from: auth)
    }
    
    func create(req: Request) async throws -> RealNameAuthResponse {
        let dto = try req.content.decode(CreateRealNameAuthRequest.self)
            
        // 验证身份证号格式
        guard dto.idCard.isValidIdCard else {
            throw Abort(.badRequest, reason: "身份证号格式不正确")
        }
            
        // 检查用户是否已认证
        let existingAuth = try await RealNameAuth.query(on: req.db)
            .filter(\RealNameAuth.$user.$id == dto.userId)
            .first()
            
        if existingAuth != nil {
            throw Abort(.conflict, reason: "用户已提交实名认证")
        }
            
        // 创建模型并保存
        let auth = RealNameAuth(from: dto)
        try await auth.save(on: req.db)
            
        // 返回安全的响应DTO（不包含身份证号等敏感信息）
        return RealNameAuthResponse(from: auth)
    }
    
    func update(req: Request) async throws -> RealNameAuthResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的认证ID")
        }
            
        guard let auth = try await RealNameAuth.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "未找到认证记录")
        }
            
        let verifyData = try req.content.decode(VerifyRealNameAuthRequest.self)
            
        // 验证状态
        guard verifyData.isValidStatus() else {
            throw Abort(.badRequest, reason: "无效的审核状态")
        }
            
        // 更新状态
        auth.status = verifyData.status
        auth.rejectReason = verifyData.reason
        auth.verifiedAt = Date()
            
        try await auth.save(on: req.db)
            
        return RealNameAuthResponse(from: auth)
    }
    
    // 软删除角色
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的认证ID")
        }
            
        guard let auth = try await RealNameAuth.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "未找到认证记录")
        }
            
        // ✅ 软删除：设置删除时间戳
        auth.deletedAt = Date()
        try await auth.save(on: req.db)
            
        return .ok
    }
    
    // 恢复删除
    func restore(req: Request) async throws -> RealNameAuthResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的认证ID")
        }
            
        // 查找已删除的记录
        guard let auth = try await RealNameAuth.query(on: req.db)
            .filter(\.$deletedAt != nil)
            .filter(\RealNameAuth.$id == id)
            .first() else {
            throw Abort(.notFound, reason: "未找到已删除的认证记录")
        }
            
        // 恢复记录（设置deletedAt为nil）
        auth.deletedAt = nil
        try await auth.save(on: req.db)
            
        return RealNameAuthResponse(from: auth)
    }
}
