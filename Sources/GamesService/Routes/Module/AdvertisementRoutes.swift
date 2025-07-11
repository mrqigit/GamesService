//
//  AdvertisementRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

struct AdvertisementRoutes {
    let controller = AdvertisementController()
    
    func register(on routes: any RoutesBuilder) {
        let ads = routes.grouped("ads")
        
        ads.get(use: controller.index)
        ads.post(use: controller.create)
        ads.post("delete",use: controller.delete)
    }
}
