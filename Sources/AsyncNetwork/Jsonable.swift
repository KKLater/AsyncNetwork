//
//  Jsonable.swift
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

/// SnakeCase naming protocol
/// If a `class` or `struct` complies with this protocol
/// and also complies with the `JSONEncodable`/`JSONDecodable` protocol, then when `encode`/`decode`,
/// set the `keyEncodingStrategy` of the `JSONEncoder`/`JSONDecoder` to `.convertToSnakeCase`.
public protocol SnakeCaseable {}

///JSON Encode parsing protocol
public protocol JSONEncodable: Encodable {
    /// Parse to JSON String
    func jsonString() throws -> String?
    
    /// Parse to any JSON such as `String`/`Dictionary`/`Array`
    func json() throws -> Any
}

public extension JSONEncodable {
    func jsonString() throws -> String? {
        let encode = JSONEncoder()
        encode.outputFormatting = .prettyPrinted
        if let _ = self as? SnakeCaseable {
            encode.keyEncodingStrategy = .convertToSnakeCase
        }

        let data = try encode.encode(self)
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    func json() throws -> Any {
        let encode = JSONEncoder()
        encode.outputFormatting = .prettyPrinted
        if let _ = self as? SnakeCaseable {
            encode.keyEncodingStrategy = .convertToSnakeCase
        }
        let data = try encode.encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        return json
    }

}

/// JSON Decode Protocol
public protocol JSONDecodable: Decodable {
    ///Resolve any JSON to an object
    static func object(fromJson json: Any) throws -> Self
    
    ///Resolve the data to an object
    static func object(from data: Data) throws -> Self
}

public extension JSONDecodable {
    static func object(fromJson json: Any) throws -> Self {
        let data = try Data.getJsonData(with: json)
        let object = try object(from: data)
        return object
    }
    
    static func object(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        if self is SnakeCaseable.Type {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        let model = try decoder.decode(Self.self, from: data) as Self
        return model
    }
}
