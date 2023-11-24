//
//  Header.swift
//  RRCNetwork
//
//  Created by 罗树新 on 2020/10/2.
//
//  MIT License
//
//  Copyright (c) 2023 Later
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public typealias Headers = [String: String]

public extension Headers {
    
    /// Supplement header information in the form of Dictionary
    /// - Parameter dictionary: header information Dictionary
    mutating func append(_ dictionary: [String : String]) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
}

/// Common request header information configuration
public struct Header: JSONEncodable {
    
    /// Tell the server which types of information the client can handle, 
    /// such as text/plain, application/json, and so on.
    public var accept: String?
    
    /// Set the encoding method for form submission data.
    public var acceptCharset: String?
    
    /// Tell the server which languages the client can handle, 
    /// such as zh-CN, zh;q=0.8, en-US;q=0.5, en;q=0.3.
    public var acceptLanguage: String?
    
    /// Tell the server which compression encoding types are supported by the client.
    /// Common compression encoding types include gzip and deflate.
    public var acceptEncoding: String?
    
    /// For identity authentication, Bearer or Basic authentication methods are generally used, 
    /// with the specific format being Bearer <token> or Basic <base64 encoded username:password>.
    public var authorization: String?
    
    /// An extension to the MIME protocol that indicates how MIME user agents should display additional files.
    public var contentDisposition: String?
    
    /// Tell the server the type of data sent,
    /// such as application/json, application/x-www-form-urlencoded, and so on.
    public var contentType: String?
    
    /// Tell the server the name and version of the client,
    /// such as Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36.
    public var userAgent: String?
    
    /// Build the header information
    /// - Returns: Header information
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
