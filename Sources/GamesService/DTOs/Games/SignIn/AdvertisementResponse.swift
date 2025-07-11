//
//  AdvertisementResponse.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

struct AdvertisementResponse: Content {
    let id: UUID?
    let title: String
    let imageUrl: String
    let linkUrl: String
    let position: AdPosition
    let source: AdSource
    let startDate: Date
    let endDate: Date
    let status: AdStatus
    let sortOrder: Int
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    
    init(from model: Advertisement) {
        self.id = model.id
        self.title = model.title
        self.imageUrl = model.imageUrl
        self.linkUrl = model.linkUrl
        self.position = model.position
        self.source = model.source
        self.startDate = model.startDate
        self.endDate = model.endDate
        self.status = model.status
        self.sortOrder = model.sortOrder
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
        self.deletedAt = model.deletedAt
    }
}

struct CreateAdvertisementRequest: Content, Validatable {
    let title: String
    let imageUrl: String
    let linkUrl: String
    let position: AdPosition
    let source: AdSource
    let startDate: Date
    let endDate: Date
    let status: AdStatus
    let sortOrder: Int
    
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty, required: true)
        validations.add("imageUrl", as: String.self, is: !.empty, required: true)
        validations.add("linkUrl", as: String.self, is: !.empty, required: true)
        validations.add("position", as: AdPosition.self, required: true)
        validations.add("source", as: AdSource.self, required: true)
        validations.add("startDate", as: Date.self, required: true)
        validations.add("endDate", as: Date.self, required: true)
        validations.add("status", as: AdStatus.self, required: true)
        validations.add("sortOrder", as: Int.self, required: true)
    }
}
