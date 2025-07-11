//
//  AdvertisementController.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor
import FluentKit

struct AdvertisementController {
    
    func index(req: Request) async throws -> Page<AdvertisementResponse> {
        
        let pageRequest = try req.query.decode(PageRequest.self)
        
        let now = Date()
                
        // 查询所有当前有效的、未删除的广告，并按排序序号排序
        return try await Advertisement.query(on: req.db)
            .filter(\.$status == .active)
            .filter(\.$deletedAt == nil)  // 排除已删除的广告
            .group(.and) { group in
                // 广告必须同时满足：已开始 且 未结束
                group.filter(\.$startDate <= now)
                group.filter(\.$endDate >= now)
            }
            .sort(\.$sortOrder, .ascending)
            .paginate(pageRequest).map { adv in
                AdvertisementResponse(from: adv)
            }
    }
    
    func create(req: Request) async throws -> AdvertisementResponse {
        // 解码请求数据
        let request = try req.content.decode(CreateAdvertisementRequest.self)
            
        // 验证日期逻辑（结束日期必须晚于开始日期）
        guard request.endDate > request.startDate else {
            throw Abort(.badRequest, reason: "结束日期必须晚于开始日期")
        }
            
        // 创建新广告
        let ad = Advertisement(
            title: request.title,
            imageUrl: request.imageUrl,
            linkUrl: request.linkUrl,
            position: request.position,
            source: request.source,
            startDate: request.startDate,
            endDate: request.endDate,
            status: request.status,
            sortOrder: request.sortOrder
        )
            
        // 保存到数据库
        try await ad.save(on: req.db)
            
        // 返回创建的广告信息
        return AdvertisementResponse(from: ad)
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let adId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "无效的广告ID")
        }
            
        guard let ad = try await Advertisement.find(adId, on: req.db) else {
            throw Abort(.notFound, reason: "广告不存在")
        }
            
        // 执行软删除
        try await ad.delete(on: req.db)
            
        return .ok
    }
}
