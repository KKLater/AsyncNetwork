//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/7/1.
//

import Foundation
/// 请求结果解析协议
public protocol Responseable: JSONDecodable {}

/// 请求结果配置类型协议
public protocol ResponseDecodable {
    associatedtype ResponseType: Responseable
}

public extension ResponseDecodable {
    
    static func object(from json: Any) throws -> ResponseType {
        return try ResponseType.object(fromJson: json)
    }
    
    static func object(from data: Data) throws -> ResponseType {
        return try ResponseType.object(from: data)
    }
}

public struct Response<ResponseType> {
    
    public var result: ResponseType
    
    /// 请求结果
    public var data: Data?
    
    public weak var request: Request?

    public var urlRequest: URLRequest?
    
    /// 请求返回结果
    public var urlResponse: HTTPURLResponse?

    /// The final metrics of the response.
    ///
    /// - Note: Due to `FB7624529`, collection of `URLSessionTaskMetrics` on watchOS is currently disabled.`
    ///
    public var metrics: URLSessionTaskMetrics?

    /// The time taken to serialize the response.
    public var serializationDuration: TimeInterval = 0.0
}

extension Response {
    public var isSuccess: Bool {
        urlResponse?.zeus.isSuccess ?? false
    }
    
    public var isFailed: Bool {
        !isSuccess
    }
    
    public var isRedirect: Bool {
        urlResponse?.zeus.isRedirect ?? false
    }
    
    public var isClientError: Bool {
        urlResponse?.zeus.isClientError ?? false
    }
    
    public var isServerError: Bool {
        urlResponse?.zeus.isServerError ?? false
    }
}

extension Response where ResponseType == Data {
    public func getJson() throws -> Any {
        let dict = try JSONSerialization.jsonObject(with: result, options: .mutableLeaves)
        return dict
    }
}
