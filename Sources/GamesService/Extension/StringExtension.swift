//
//  StringExtension.swift
//  GamesService
//
//  Created by MrQi on 2025/7/9.
//

import Foundation

extension String? {
    var isEmpty: Bool {
        if let self = self {
            return self.isEmpty
        }
        return true
    }
    
    var isNotEmpty: Bool {
        if let self = self {
            return self.isNotEmpty
        }
        return false
    }
    
    /// 身份证号格式验证
    var isValidIdCard: Bool {
        if let self = self {
            return self.isValidIdCard
        }
        return false
    }
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    /// 身份证号格式验证
    var isValidIdCard: Bool {
        let pattern = "^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$"
        return NSPredicate(format: "SELF MATCHES %@", pattern)
            .evaluate(with: self)
    }
    
    static func == (lhs: String, rhs: String?) -> Bool {
        // 比较规则：title和author都相等时返回true
        if let rhs = rhs {
            return lhs == rhs
        }
        return false
    }
    
    func isEqual(_ str: String?) -> Bool {
        if let str = str {
            return self == str
        }
        return false
    }
}
