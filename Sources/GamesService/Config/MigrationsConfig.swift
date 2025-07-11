//
//  MigrationsConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor

public func configureMigrations(_ app: Application) {
    app.migrations.add(CreateRoles())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateRealNameAuth())
    app.migrations.add(CreateAdvertisements())
    app.migrations.add(CreateSignInRecord())
    app.migrations.add(CreateSignInConfig())
    app.migrations.add(CreateSignInRewardLog())
    app.migrations.add(CreatePuzzleLevels())
    app.migrations.add(CreatePuzzleLevelConfigs())
    app.migrations.add(CreateUserPuzzleProgress())
    app.migrations.add(CreatePuzzleLevelRewards())
}
