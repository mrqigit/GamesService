//
//  Advertisement.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Fluent
import Vapor

// 广告位置枚举
enum AdPosition: String, Codable {
    case carousel = "carousel"    // 顶部轮播
    case banner = "banner"      // 中部横幅
    case footer = "footer"      // 底部推荐
    case sidebar = "sidebar"    // 侧边栏
}

// 广告状态枚举
enum AdStatus: String, Codable {
    case active = "active"      // 启用
    case inactive = "inactive"  // 禁用
}

// 广告来源枚举
enum AdSource: String, Codable {
    case `internal` = "internal"    // 内部运营
    case tencent = "tencent"      // 腾讯广告
    case baidu = "baidu"        // 百度广告
    case alibaba = "alibaba"    // 阿里广告
    case thirdParty = "third_party"  // 其他第三方
}

// 广告模型
final class Advertisement: Model, Content, @unchecked Sendable {
    static let schema = "advertisements"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "image_url")
    var imageUrl: String
    
    @Field(key: "link_url")
    var linkUrl: String
    
    @Field(key: "position")
    var position: AdPosition
    
    @Field(key: "source")
    var source: AdSource
    
    @Field(key: "start_date")
    var startDate: Date
    
    @Field(key: "end_date")
    var endDate: Date
    
    @Field(key: "status")
    var status: AdStatus
    
    @Field(key: "sort_order")
    var sortOrder: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        title: String,
        imageUrl: String,
        linkUrl: String,
        position: AdPosition,
        source: AdSource,
        startDate: Date,
        endDate: Date,
        status: AdStatus,
        sortOrder: Int
    ) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.linkUrl = linkUrl
        self.position = position
        self.source = source
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.sortOrder = sortOrder
    }
}
