//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/14.
//

import Foundation

extension HTTPURLResponse: ZeusCompatible {}
public extension ZeusWrapper where Base: HTTPURLResponse {
    var isSuccess: Bool {
        return wrapper.statusCode == 200
    }
    
    var isFailed: Bool {
        return !isSuccess
    }
    
    var isRedirect: Bool {
        if isSuccess { return false }
        let range = 300..<400
        return range.contains(wrapper.statusCode)
    }
    
    var isClientError: Bool {
        if isSuccess { return false }
        let range = 400..<500
        return range.contains(wrapper.statusCode)
    }
    
    var isServerError: Bool {
        if isSuccess { return false }
        let range = 500..<600
        return range.contains(wrapper.statusCode)
    }
    
    var localizedString: String {
        return HTTPURLResponse.localizedString(forStatusCode: wrapper.statusCode)
    }
}
