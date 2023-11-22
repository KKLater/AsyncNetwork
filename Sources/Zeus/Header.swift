//
//  Header.swift
//  RRCNetwork
//
//  Created by 罗树新 on 2020/10/2.
//

import Foundation

public typealias Headers = [String: String]

public extension Headers {
    
    /// 以 dic 方式补充头信息
    /// - Parameter dic: 头信息dic
    mutating func append(_ dic: [String : String]) {
        for (key, value) in dic {
            self[key] = value
        }
    }
}

/// 通用 Header
public struct Header: JSONEncodable {
    
    public var accept: String?
    
    public var acceptCharset: String?
    
    public var acceptLanguage: String?
    
    public var acceptEncoding: String?
    
    public var authorization: String?
    
    public var contentDisposition: String?
    
    public var contentType: String?
    
    public var userAgent: String?
        
    public func headers() -> Headers {
        let dic = try? json() as? Headers
        return dic ?? [:]
    }
    
    public init() {}
}

private extension Header {
     enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case acceptCharset = "Accept-Charset"
        case acceptLanguage = "Accept-Language"
        case acceptEncoding = "Accept-Encoding"
        case authorization = "Authorization"
        case contentDisposition = "Content-Disposition"
        case contentType = "Content-Type"
        case userAgent = "User-Agent"
    }
}
