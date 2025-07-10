//
//  MigrationsConfig.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor

public func configureMigrations(_ app: Application) {
    app.migrations.add(CreateRoles())
    app.migrations.add(CreateRealNameAuth())
    app.migrations.add(CreateUser())
}
