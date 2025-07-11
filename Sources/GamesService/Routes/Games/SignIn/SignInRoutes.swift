//
//  SignInRoutes.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

struct SignInRoutes {
    let controller = SignInController()
    
    func register(on routes: any RoutesBuilder) {
        let signIn = routes.grouped("signIn")
        
        signIn.get("status", use: controller.getSignInStatus)
        signIn.post(use: controller.signIn)
        signIn.post("claim", use: controller.claimReward)
    }
}
