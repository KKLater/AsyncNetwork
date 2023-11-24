//
//  Response.swift
//  
//
//  Created by 罗树新 on 2023/7/1.
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
/// Request result parsing protocol
public protocol Responseable: JSONDecodable {}

/// Request result configuration type protocol
public protocol ResponseDecodable {
    associatedtype ResponseType: Responseable
}

public extension ResponseDecodable {
    
    /// Parse JSON into an instance object
    /// - Parameter json: JSON data
    /// - Returns: instance object
    static func object(from json: Any) throws -> ResponseType {
        return try ResponseType.object(fromJson: json)
    }
    
    /// Parse Data into an instance object
    /// - Parameter data: binary data
    /// - Returns: instance object
    static func object(from data: Data) throws -> ResponseType {
        return try ResponseType.object(from: data)
    }
}

public struct Response<ResponseType> {
    
    public var result: ResponseType
    
    public var data: Data?
    
    public weak var request: Request?

    public var urlRequest: URLRequest?
    
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
        urlResponse?.async.isSuccess ?? false
    }
    
    public var isFailed: Bool {
        !isSuccess
    }
    
    public var isRedirect: Bool {
        urlResponse?.async.isRedirect ?? false
    }
    
    public var isClientError: Bool {
        urlResponse?.async.isClientError ?? false
    }
    
    public var isServerError: Bool {
        urlResponse?.async.isServerError ?? false
    }
}

extension Response where ResponseType == Data {
    public func getJson() throws -> Any {
        let dict = try JSONSerialization.jsonObject(with: result, options: .mutableLeaves)
        return dict
    }
}
