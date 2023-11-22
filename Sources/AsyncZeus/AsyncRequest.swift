//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/7.
//

#if canImport(Async)
import Foundation
import Zeus
import Async

extension Async {
    
    public enum RequestError: Error {
        case responseNil
        case responseDecodeFailed
    }
    
    public struct Request {
        
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
        
        public class JSONTask<RequestType: Requestable>: AsyncTaskType {
            public typealias Success = Any
            
            public typealias Failure = Error
            
            public func action(closure: @escaping () -> Void) {
                request.responseJson(token: token) { result in
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
        
        public class ResponseTask<RequestType>: AsyncTaskType where RequestType: Requestable {
            
            public typealias Success = Response<Data>
            
            public typealias Failure = Error
            
            public func action(closure: @escaping () -> Void) {
                let request = Zeus.Request(requestOptions: request, token: token)
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

extension Zeus.Requestable {
    
    public func responseTask(token: String? = nil) -> Async.Request.ResponseTask<Self> {
        return Async.Request.ResponseTask(request: self, token: token)
    }
   
    public func responseDataTask(token: String? = nil) -> Async.Request.DataTask<Self> {
        return Async.Request.DataTask(request: self, token: token)
    }
    
    public func responseJsonTask(token: String? = nil) -> Async.Request.JSONTask<Self> {
        return Async.Request.JSONTask(request: self, token: token)
    }
}

extension Zeus.Requestable where Self: ResponseDecodable {
    public func responseDecodeableTask(token: String? = nil) -> Async.Request.DecodeTask<Self> {
        return Async.Request.DecodeTask(request: self, token: token)
    }
}



#endif
