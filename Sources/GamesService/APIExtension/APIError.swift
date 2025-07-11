//
//  APIError.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

enum APIError: Error, Content {
    case unauthorized
    case forbidden
    case notFound
    case badRequest(String)
    case internalServerError
    
    var code: Int {
        switch self {
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .badRequest: return 400
        case .internalServerError: return 500
        }
    }
    
    var message: String {
        switch self {
        case .unauthorized: return "未授权"
        case .forbidden: return "禁止访问"
        case .notFound: return "资源不存在"
        case .badRequest(let msg): return msg
        case .internalServerError: return "服务器内部错误"
        }
    }
}
