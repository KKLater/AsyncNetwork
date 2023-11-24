//
//  AsyncExtension.swift
//
//
//  Created by 罗树新 on 2023/11/7.
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

extension Async {
    
    public enum RequestError: Error {
        case responseNil
        case responseDecodeFailed
    }
    
    public struct Request {
        
        /// When the task is completed, the returned result is binary data
        public class DataTask<RequestType: Requestable>: AsyncTaskType {
            
            public typealias Success = Data
            
            public typealias Failure = Error
            
            public func action(closure: @escaping () -> Void) {
                request.responseData(token: token) { result in
                    switch result {
                    case .success(let response):
                        self.result = .success(response.result)
                    case .failure(let error):
                        self.result = .failure(error)
                    }
                    closure()
                }
            }
            
            public var result: Result<Data, Error>?
            
            var request: RequestType
            var token: String?
            init(request: RequestType, token: String? = nil) {
                self.request = request
            }
        }
        
        /// When the task is completed, the returned result is JSON, such as `String`/`Dictionary`/`Array`
        public class JSONTask<RequestType: Requestable>: AsyncTaskType {
            public typealias Success = Any
            
            public typealias Failure = Error
            
            public func action(closure: @escaping () -> Void) {
                request.responseJSON(token: token) { result in
                    switch result {
                    case .success(let response):
                        self.result = .success(response.result)
                    case .failure(let error):
                        self.result = .failure(error)
                    }
                    closure()
                }
            }
            
            public var result: Result<Any, Error>?
            
            var request: RequestType
            var token: String?
            init(request: RequestType, token: String? = nil) {
                self.request = request
            }
        }
        
        /// When the task is completed, the returned result is an instance object of `ResponseType`
        public class DecodeTask<RequestType>: AsyncTaskType where RequestType: Requestable & ResponseDecodable {
            
            public typealias Success = RequestType.ResponseType
            
            public typealias Failure = Error
            
            public func action(closure: @escaping () -> Void) {
                request.responseDecodable(token: token) { result in
                    switch result {
                    case .success(let response):
                        self.result = .success(response.result)
                    case .failure(let error):
                        self.result = .failure(error)
                    }
                    closure()
                }
                
            }
            
            public var result: Result<RequestType.ResponseType, Error>?
            
            var request: RequestType
            var token: String?
            init(request: RequestType, token: String? = nil) {
                self.request = request
            }
        }
        
        /// When the task is completed, the returned result is an instance object of `Response<Data>`
        public class ResponseTask<RequestType>: AsyncTaskType where RequestType: Requestable {
            
            public typealias Success = Response<Data>
            
            public typealias Failure = Error
            
            public func action(closure: @escaping () -> Void) {
                let request = AsyncNetwork.Request(requestOptions: request, token: token)
                request.execute { result in
                    self.result = result
                    closure()
                }
            }
            
            public var result: Result<Response<Data>, Error>?
            
            var request: RequestType
            var token: String?
            init(request: RequestType, token: String? = nil) {
                self.request = request
            }
        }
    }
}

extension AsyncNetwork.Requestable {
    
    /// Build an instance object of `ResponseTask`
    /// - Parameter token: The requested token
    /// - Returns: Response request task
    public func responseTask(token: String? = nil) -> Async.Request.ResponseTask<Self> {
        return Async.Request.ResponseTask(request: self, token: token)
    }
    
    /// Build an instance object of `DataTask`
    /// - Parameter token: The requested token
    /// - Returns: Response request task
    public func responseDataTask(token: String? = nil) -> Async.Request.DataTask<Self> {
        return Async.Request.DataTask(request: self, token: token)
    }
    
    /// Build an instance object of `JSONTask`
    /// - Parameter token: The requested token
    /// - Returns: Response request task
    public func responseJSONTask(token: String? = nil) -> Async.Request.JSONTask<Self> {
        return Async.Request.JSONTask(request: self, token: token)
    }
}

extension AsyncNetwork.Requestable where Self: ResponseDecodable {
    
    /// Build an instance object of `DecodeTask`
    /// Construct a Decode request task for network requests that conform to the ResponseDecodable protocol. You can directly obtain a ResponseType instance at the end of the request.
    ///
    /// - Parameter token: The requested token
    /// - Returns: Response request task
    public func responseDecodeTask(token: String? = nil) -> Async.Request.DecodeTask<Self> {
        return Async.Request.DecodeTask(request: self, token: token)
    }
}

