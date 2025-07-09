//
//  RealNameAuth.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Fluent
import Vapor

final class RealNameAuth: Model, Content, @unchecked Sendable {
    
    static let schema = "real_name_auths"
    
    @ID(key: .id)
    var id: UUID?
        
    @Parent(key: "user_id")
    var user: User
        
    @Field(key: "real_name")
    var realName: String
        
    @Field(key: "id_card")
    var idCard: String
        
    @Field(key: "id_card_front_url")
    var idCardFrontUrl: String?
        
    @Field(key: "id_card_back_url")
    var idCardBackUrl: String?
        
    @Field(key: "status")
    var status: Int // 0: 待审核, 1: 通过, 2: 拒绝
        
    @Field(key: "reject_reason")
    var rejectReason: String?
        
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
        
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
        
    @Timestamp(key: "verified_at", on: .none)
    var verifiedAt: Date?
        
    @Field(key: "deleted_at")
    var deletedAt: Date?
    
    init() {}
    
    init(
        userId: UUID,
        realName: String,
        idCard: String,
        idCardFrontUrl: String? = nil,
        idCardBackUrl: String? = nil,
        status: Int = 0
    ) {
        self.$user.id = userId
        self.realName = realName
        self.idCard = idCard
        self.idCardFrontUrl = idCardFrontUrl
        self.idCardBackUrl = idCardBackUrl
        self.status = status
    }
    
    convenience init(from dto: CreateRealNameAuthRequest) {
        self.init(
            userId: dto.userId,
            realName: dto.realName,
            idCard: dto.idCard,
            idCardFrontUrl: dto.idCardFrontUrl,
            idCardBackUrl: dto.idCardBackUrl
        )
    }
}
