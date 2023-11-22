//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/14.
//

import Foundation

extension Data: ZeusCompatible {}
extension ZeusWrapper where Base == Data {
    static func getJsonData(with json: Any) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return data
    }
    
    func mapping(by designatedPath: String) throws -> Data {
        let keys = designatedPath.components(separatedBy: ".")
        guard keys.count > 0 else { return wrapper }
        
        let json = try JSONSerialization.jsonObject(with: wrapper, options: .allowFragments)

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
                throw ZeusError.ResponseError.parsingKeysFailed(currentKey)
            }
            /// 不能再继续解析
            guard let jsonCallBackResult = callBackResult as? [String: Any] else {
                throw ZeusError.ResponseError.parsingKeysFailed(currentKey)
            }
            
            /// 后续数据解析 key 不存在
            guard let tempCallBackResult = jsonCallBackResult[tempKey] else {
                throw ZeusError.ResponseError.parsingKeysFailed(currentKey)
            }
            
            if tempKey == lastKey {
                /// 最后一个key了，可以直接返回，不需要区分是不是 dic
                callBackResult = tempCallBackResult
                break
            }
            
            /// 不是最后一个key，需要判断新的数据是不是json，
            guard let tempCallBackResult = tempCallBackResult as? [String: Any] else {
                throw ZeusError.ResponseError.parsingKeysFailed(currentKey)
            }
            
            callBackResult = tempCallBackResult
        }
        
        let data = try JSONSerialization.data(withJSONObject: callBackResult)
        return data
        
    }
}
