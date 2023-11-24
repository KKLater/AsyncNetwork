//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/23.
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

/// RequestManager is used to manage network requests. After the request is initiated, it temporarily stores the request and can request a retry or cancel the request.
/// completely relies on the Request's token to manage related requests.
public class RequestManager {
    public static let shared = RequestManager()
    
    private var requests = [String: Request]()
    
    /// Cancel the network request
    /// - Parameter token: request token
    public func cancelRequest(for token: String) {
        var requests = self.requests
        if let _ = requests[token] {
            requests.removeValue(forKey: token)
            self.requests = requests
        }
    }
    
    /// Cancel all network requests
    public func cancelAll() {
        var requests = self.requests
        
        Session.shared.cancelAll()
        requests.removeAll()
        self.requests = requests
    }
    
    /// Retry the request
    /// - Parameter token: Request token
    /// - Returns: Whether the request was successfully retried
    @discardableResult
    public func retryRequest(for token: String) -> Bool {
        guard let request = requests[token] else {
            return false
        }
        if let completion = request.completion {
            request.execute(completion: completion )
            return true
        }
        
        return false
    }
}

extension RequestManager {
    
    func save(request: Request, for cancelToken: String) {
        var requests = self.requests
        if requests[cancelToken] != nil {
            return
        }
        requests[cancelToken] = request
        self.requests = requests
    }
}
