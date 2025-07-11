//
//  ErrorHandlingMiddleware.swift
//  GamesService
//
//  Created by MrQi on 2025/7/10.
//

import Vapor

// 定义错误处理中间件
struct ErrorHandlingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            // 执行下一个中间件或路由处理函数
            let response = try await next.respond(to: request)
            
            // 只处理成功的 JSON 响应
            if let contentType = response.headers.contentType?.type, contentType == "application" {
                        
                do {
                    // 尝试将响应内容转换为 JSONDictionary
                    if let jsonData = response.body.data {
                        let decoder = JSONDecoder()
                        let jsonDictionary = try decoder.decode(
                            JSONDictionary.self,
                            from: jsonData
                        )
                                
                        // 创建包装响应
                        let wrappedResponse = APIResponse(
                            code: Int(response.status.code),
                            message: "success",
                            data: jsonDictionary
                        )
                                
                        // 编码并设置新的响应内容
                        let encoder = JSONEncoder()
                        response.body = try .init(
                            data: encoder.encode(wrappedResponse)
                        )
                        response.headers.contentType = .json
                    }
                } catch {
                    request.logger.warning("Failed to wrap response: \(error)")
                }
            }
            
            return response
        } catch let abort as Abort {
            return Response(
                status: .internalServerError,
                body: try .init(data: JSONEncoder().encode(APIResponse(code: Int(abort.status.code), message: abort.reason)))
            )
        } catch {
            let error = APIError.internalServerError
            return Response(
                status: .internalServerError,
                body: try .init(data: JSONEncoder().encode(APIResponse(code: error.code, message: error.message)))
            )
        }
    }
}
