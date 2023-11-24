//
//  Handleable.swift
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

public protocol Handleable {}

public protocol RequestHandleable {
    
    /// Intercept processing before request initiation
    /// Return `Result` and intercept interruption. Requests directly return this `Result`.
    /// If you need to request to continue, return `nil`
    ///
    /// - Parameter request: The request to be processed
    func handle(_ request: Request) -> Result<Response<Data>, Error>?
}

public protocol ResponseHandleable {
    
    /// Intercept and process the response after obtaining it
    /// Return a `Result`, if it is success, the subsequent interceptors will iterate the new `Result`.
    /// If `failure` is returned, the iteration terminates and return this `error`.
    ///
    /// - Parameter response: request response
    func handle(_ response: Result<Response<Data>, Error>) -> Result<Response<Data>, Error>?
}
