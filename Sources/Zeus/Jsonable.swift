//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/7/1.
//

import Foundation

public protocol SnakeCaseable {}

public protocol JSONEncodable: Encodable {
    func jsonString() throws -> String?
    func json() throws -> Any
}

public extension JSONEncodable {

    /// 解析为jsonString
    /// - Returns: json string
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

public protocol JSONDecodable: Decodable {
    static func object(fromJson json: Any) throws -> Self
    static func object(from data: Data) throws -> Self
}

public extension JSONDecodable {
    
    /// 将可以解析为 object 的json 解析为 object
    /// - Parameter json: 需要解析的json
    /// - Returns: 解析成功的object
    static func object(fromJson json: Any) throws -> Self {
        let data = try Data.zeus.getJsonData(with: json)
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
