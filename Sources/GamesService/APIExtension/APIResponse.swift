//
//  APIResponse.swift
//  GamesService
//
//  Created by MrQi on 2025/7/11.
//

import Vapor

// 使用 Codable 兼容的字典替代 [String: Any]
struct JSONDictionary: Codable, Sendable {
    private let storage: [String: JSONValue]
    
    init(_ dictionary: [String: JSONValue]) {
        self.storage = dictionary
    }
    
    subscript(key: String) -> JSONValue? {
        return storage[key]
    }
    
    // 实现 Decodable
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.storage = try container.decode([String: JSONValue].self)
    }
    
    // 实现 Encodable
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
}

// 支持基本 JSON 类型的值
enum JSONValue: Codable, Sendable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([JSONValue])
    case dictionary(JSONDictionary)
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(JSONDictionary.self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Failed to decode JSONValue"
            ))
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}

// 修改 APIResponse 以接受 JSONContent
struct APIResponse: Content, Sendable {
    let code: Int
    let message: String
    let data: JSONDictionary?
    
    init(code: Int, message: String, data: JSONDictionary? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
