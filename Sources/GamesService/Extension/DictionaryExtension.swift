//
//  DictionaryExtension.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Foundation

extension Dictionary {
    var toJsonString: String {
        do {
            // 1. 将字典转换为 JSON 数据
            let jsonData = try JSONSerialization.data(
                withJSONObject: self,
                options: .prettyPrinted // 可选：格式化输出
            )
            
            // 2. 将数据转换为字符串
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return "JSON 序列化失败\(jsonData)"
            }
            
            return jsonString
        } catch {
            return "JSON 序列化失败：\(error)"
        }
    }
}
