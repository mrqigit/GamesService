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
        let pageRequest = try req.query.decode(PageRequest.self)
        
        // 执行查询并预加载关联数据
        let userPage = try await User.query(on: req.db)
            .with(\.$role)
            .with(\.$realNameAuth)
            .filter(\.$deletedAt == nil)
            .sort(\.$createdAt, .descending)
            .paginate(pageRequest)
        
        // 转换为响应DTO
        return try userPage.map { user in
            guard let role = user.$role.value else {
                throw Abort(.internalServerError, reason: "角色关联丢失")
            }
            
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
        
        // 创建用户
        let user = User(
            username: dto.username,
            email: dto.email,
            passwordHash: passwordHash,
        )
        
        try await user.save(on: req.db)
        
        guard let defaultRole = try await Role.query(on: req.db).filter(\.$type == "user").first() else {
            throw Abort(.internalServerError, reason: "未找到角色")
        }
        
        return UserResponse(
            from: user,
            role: RoleResponse(from: defaultRole),
            auth: nil
        )
    }
    
    // 获取单个用户
    func show(req: Request) async throws -> UserResponse {
        let id: UUID = try req.query.get(UUID.self, at: "id")
        
        // 查询用户及其关联数据
        let user = try await User.query(on: req.db)
            .with(\.$role)
            .with(\.$realNameAuth)
            .filter(\.$id == id)
            .first()
        if user == nil {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
        // 在同一事务中查询最新数据
        guard let updatedUser = try await User.query(on: req.db)
            .with(\.$role)
            .with(\.$realNameAuth)
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
    
    // 更新用户
    func update(req: Request) async throws -> UserResponse {
        
        let dto = try req.content.decode(UpdateUserRequest.self)
        
        guard let user = try await User.find(dto.id, on: req.db) else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
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
        
        // 在事务中执行更新
        try await user.save(on: req.db)
            
        // 在同一事务中查询最新数据
        guard let updatedUser = try await User.query(on: req.db)
            .with(\.$role)
            .with(\.$realNameAuth)
            .filter(\.$id == dto.id)
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
    
    // 软删除用户
    func delete(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(UpdateUserRequest.self)
        
        guard let user = try await User.find(dto.id, on: req.db) else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        
        user.deletedAt = Date()
        
        try await user.update(on: req.db) // 软删除
        return .ok
    }
    
    // 恢复已删除用户
    func restore(req: Request) async throws -> UserResponse {
        let dto = try req.content.decode(UpdateUserRequest.self)
        
        // 查找已删除的用户
        guard let user = try await User.query(on: req.db)
            .with(\.$role)
            .filter(\.$id == dto.id)
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
            .filter(\.$id == dto.id)
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
        let credentials = try req.content.decode(LoginRequest.self)
        try credentials.validate()
        
        // 查询用户并预加载角色
        guard let user = try await User.query(on: req.db)
            .with(\.$role)
            .with(\.$realNameAuth)
            .filter(\.$username == credentials.username)
            .first() else {
            throw Abort(.unauthorized, reason: "用户名不存在")
        }
        
        // 验证密码
        guard try Bcrypt.verify(credentials.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "密码错误")
        }
        
        // 创建 JWT
        let payload = try UserPayload(user: user)
        let token = try req.jwt.sign(payload)
        
        return LoginResponse(
            token: token,
            user: UserResponse(
                from: user,
                role: RoleResponse(from: user.role),
                auth: RealNameAuthResponse(from: user.realNameAuth!)
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
