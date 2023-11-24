//
//  HTTPURLResponseExtension.swift
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
import Async

extension HTTPURLResponse: AsyncCompatible {}
public extension AsyncWrapper where Base: HTTPURLResponse {
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
