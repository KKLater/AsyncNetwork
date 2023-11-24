//
//  DataExtension.swift
//  
//
//  Created by 罗树新 on 2023/11/14.
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

extension Data {
    static func getJsonData(with json: Any) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return data
    }
    
    func mapping(by designatedPath: String) throws -> Data {
        let keys = designatedPath.components(separatedBy: ".")
        guard keys.count > 0 else { return self }
        
        let json = try JSONSerialization.jsonObject(with: self, options: .allowFragments)

        var currentKey = ""
        var callBackResult: Any = json
        let lastKey = keys.last
        for tempKey in keys {
            
            if currentKey.isEmpty {
                currentKey += "\(tempKey)"
            } else {
                currentKey += ".\(tempKey)"
            }
            
            if tempKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
                throw AsyncNetworkError.ResponseError.parsingKeysFailed(currentKey)
            }
            /// 不能再继续解析
            guard let jsonCallBackResult = callBackResult as? [String: Any] else {
                throw AsyncNetworkError.ResponseError.parsingKeysFailed(currentKey)
            }
            
            /// 后续数据解析 key 不存在
            guard let tempCallBackResult = jsonCallBackResult[tempKey] else {
                throw AsyncNetworkError.ResponseError.parsingKeysFailed(currentKey)
            }
            
            if tempKey == lastKey {
                /// 最后一个key了，可以直接返回，不需要区分是不是 dic
                callBackResult = tempCallBackResult
                break
            }
            
            /// 不是最后一个key，需要判断新的数据是不是json，
            guard let tempCallBackResult = tempCallBackResult as? [String: Any] else {
                throw AsyncNetworkError.ResponseError.parsingKeysFailed(currentKey)
            }
            
            callBackResult = tempCallBackResult
        }
        
        let data = try JSONSerialization.data(withJSONObject: callBackResult)
        return data
        
    }
}
