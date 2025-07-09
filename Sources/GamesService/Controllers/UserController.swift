//
//  UserController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent
import Vapor

struct UserController {
    
    // 获取用户列表
    func index(req: Request) async throws -> Page<UserResponse> {
        // 使用可选获取方法：参数不存在时返回 nil，而非抛出错误
        let page = try? req.query.get(Int.self, at: "page")
        let perPage = try? req.query.get(Int.self, at: "perPage")
           
        // 确保 page 和 perPage 不为 nil（兜底默认值）
        let safePage = page ?? 1
        let safePerPage = perPage ?? 10
        
        let pageRequest = PageRequest(page: safePage, per: safePerPage)
        
        // 执行查询并预加载关联数据
        let userPage = try await User.query(on: req.db)
            .with(\.$role)           // 预加载角色
            .with(\.$realNameAuth)   // 预加载实名认证
            .filter(\.$deletedAt == nil)  // 过滤未删除的用户
            .sort(\.$createdAt, .descending)  // 按创建时间排序
            .paginate(pageRequest)
        
        // 转换为响应DTO
        return try await userPage.map { user in
            // 使用 requireParent 获取预加载的角色
            let role = try user.requireParent(\User.$role)
            
            return UserResponse(
                from: user,
                role: RoleResponse(from: role),
                auth: user.realNameAuth.map { RealNameAuthResponse(from: $0) }
            )
        }
    }
    
    // 创建用户
    func create(req: Request) async throws -> UserResponse {
        let dto = try req.content.decode(CreateUserRequest.self)
        try dto.validate()
        
        // 检查邮箱是否已存在
        guard try await User.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() == nil else {
            throw Abort(.conflict, reason: "邮箱已被注册")
        }
        
        // 哈希密码
        let passwordHash = try Bcrypt.hash(dto.password)
        
        // 处理角色ID（核心修正点）
        let roleId: UUID
        if let dtoRoleId = dto.roleId {
            // 如果DTO提供了roleId，验证其有效性
            guard try await Role.find(dtoRoleId, on: req.db) != nil else {
                throw Abort(.badRequest, reason: "无效的角色ID")
            }
            roleId = dtoRoleId
        } else {
            // 如果未提供，使用默认角色（例如"user"角色）
            guard let defaultRole = try await Role.query(on: req.db)
                .filter(\Role.$type == "user")
                .first() else {
                throw Abort(.internalServerError, reason: "默认角色不存在，请先创建角色")
            }
            roleId = defaultRole.id! // 假设默认角色一定有ID（已保存到数据库）
        }
        
        // 创建用户
        let user = User(
            username: dto.username,
            email: dto.email,
            passwordHash: passwordHash,
            roleId: roleId // 使用确定的roleId
        )
        
        try await user.save(on: req.db)
        
        // 获取用户关联的角色（用于响应DTO）
        guard let role = try await Role.find(roleId, on: req.db) else {
            throw Abort(.internalServerError, reason: "角色信息获取失败")
        }
        
        return UserResponse(
            from: user,
            role: RoleResponse(from: role),
            auth: nil
        )
    }
    
    // 获取单个用户
    func show(req: Request) async throws -> UserResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的用户ID")
        }
        
        // 查询用户及其关联数据
        guard let user = try await User.query(on: req.db)
            .with(\.$role)
            .with(\.$realNameAuth)
            .filter(\.$id == id)
            .first() else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
        return try await UserResponse(
            from: user,
            role: user.$role.get(),
            auth: user.realNameAuth
        )
    }
    
    // 更新用户
    func update(req: Request) async throws -> UserResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的用户ID")
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
        let dto = try req.content.decode(UpdateUserRequest.self)
        
        if let username = dto.username {
            user.username = username
        }
        
        if let email = dto.email {
            if email != user.email {
                guard try await User.query(on: req.db)
                    .filter(\.$email == email)
                    .first() == nil else {
                    throw Abort(.conflict, reason: "邮箱已被注册")
                }
                user.email = email
            }
        }
        
        if let roleId = dto.roleId {
            guard let _ = try await Role.find(roleId, on: req.db) else {
                throw Abort(.notFound, reason: "角色不存在")
            }
            user.$role.id = roleId
        }
        
        if let avatarUrl = dto.avatarUrl {
            user.avatarUrl = avatarUrl
        }
        
        return try await req.db.transaction { db in
            // 在事务中执行更新
            try await user.save(on: db)
                
            // 在同一事务中查询最新数据
            guard let updatedUser = try await User.query(on: db)
                .with(\.$role)
                .filter(\.$id == id)
                .first() else {
                throw Abort(.internalServerError, reason: "更新后无法获取用户数据")
            }
            
            // ✅ 安全处理可选的角色值
            guard let role = updatedUser.$role.value else {
                throw Abort(.internalServerError, reason: "用户角色关联丢失")
            }
                
            return UserResponse(
                from: updatedUser,
                role: RoleResponse(from:role),
                auth: updatedUser.realNameAuth
                    .map { RealNameAuthResponse(from: $0) }
            )
        }
    }
    
    // 软删除用户
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的用户ID")
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
        try await user.delete(on: req.db) // 软删除
        return .ok
    }
    
    // 恢复已删除用户
    func restore(req: Request) async throws -> UserResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的用户ID")
        }
        
        // 查找已删除的用户
        guard let user = try await User.query(on: req.db)
            .with(\.$role)
            .filter(\.$id == id)
            .filter(\.$deletedAt != nil)
            .first() else {
            throw Abort(.notFound, reason: "未找到已删除的用户")
        }
        
        // 获取当前认证用户
        let currentUser = try req.auth.require(User.self)
        
        // 权限检查：只有管理员可以恢复用户
        guard try await currentUser.$role.get(on: req.db).type == "admin" else {
            throw Abort(.forbidden, reason: "只有管理员可以恢复用户")
        }
        
        // 恢复用户
        try await user.restore(on: req.db)
        
        // 返回恢复后的用户
        guard let restoredUser = try await User.query(on: req.db)
            .with(\.$role)
            .filter(\.$id == id)
            .first() else {
            throw Abort(.internalServerError, reason: "恢复后无法获取用户数据")
        }
        
        // ✅ 安全处理可选的角色值
        guard let role = restoredUser.$role.value else {
            throw Abort(.internalServerError, reason: "用户角色关联丢失")
        }
        
        return UserResponse(
            from: restoredUser,
            role: RoleResponse(from: role),
            auth: restoredUser.realNameAuth
                .map { RealNameAuthResponse(from: $0) }
        )
    }
    
    func login(req: Request) async throws -> LoginResponse {
        let request = try req.content.decode(LoginRequest.self)
        
        // 使用 queryWithDeleted 确保可以查询到已删除用户
        guard let user = try await User.query(on: req.db)
            .with(\.$role) // 预加载角色关联
            .filter(\.$email == request.email)
            .first(),
              try user.verify(password: request.password) else {
            throw Abort(.unauthorized, reason: "邮箱或密码错误")
        }
        
        // 检查用户是否已被软删除
        guard user.deletedAt == nil else {
            throw Abort(.forbidden, reason: "用户已被禁用，请联系管理员")
        }
        
        // 创建认证令牌
        let token = try user.generateToken()
        try await token.save(on: req.db)
        
        // ✅ 安全解包角色值
        guard let role = user.$role.value else {
            throw Abort(.internalServerError, reason: "用户角色关联丢失")
        }
            
        return LoginResponse(
            token: token.value,
            user: UserResponse(
                from: user,
                role: RoleResponse(from: role),  // 使用解包后的角色
                auth: user.realNameAuth.map { RealNameAuthResponse(from: $0) }
            )
        )
    }

    // 辅助方法：获取管理员角色ID
    private func getAdminRoleId(on database: any Database) async throws -> UUID {
        guard let adminRole = try await Role.query(on: database)
            .filter(\Role.$type == "admin")
            .first() else {
            throw Abort(.internalServerError, reason: "管理员角色不存在")
        }
        return adminRole.id!
    }
}
