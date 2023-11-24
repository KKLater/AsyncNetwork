//
//  Requets.swift
//  
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
import Alamofire

/// Request is a class that relies on specific instances of Requestable to build network requests and initiate network requests.
/// Request initializes request parameters from a specific instance of Requestable and initiates network requests.
/// Before the request is initiated, the interception operation will be iteratively executed to perform relevant configuration processing or end the request for the network request.
/// The request ends, and after obtaining the corresponding Response data, the interception operation will be iteratively executed again to perform relevant configuration processing or end the request for network requests and related responses.
/// Intercept its related requests, and can throw results or errors.
public class Request {
    
    /// Request configuration
    /// The instance object needs to comply with the Requestable protocol and implement its related protocol methods.
    public private(set) var requestOptions: any Requestable
    
    /// Initialize the request
    /// - Parameters:
    /// - requestOptions: Request configuration, following Requestable
    /// - token: Request token, which can be used for retrying or canceling the request. Reference: `RequestManager`
    public init(requestOptions: any Requestable, token: String? = nil) {
        self.requestOptions = requestOptions
        self.path = requestOptions.readPath()
        self.url = requestOptions.readUrl()
        self.method = requestOptions.method()
        self.parameters = requestOptions.parameters()
        self.headers = requestOptions.readHeaders()
        self.timeoutInterval = requestOptions.readTimeoutInterval()
        self.requestHandlers = requestOptions.requestHandlers()
        self.responseHandlers = requestOptions.responseHandlers()
        self.token = token ?? UUID().uuidString
        self.userDefineToken = token
    }
    
    /// Request token, which can be used for retrying or canceling the request. Reference: `RequestManager
    public var token: String
    
    /// Request URL
    public var url: String
    
    /// Request path
    public var path: String
    
    /// Request Method
    public var method: Method
    
    /// Request parameters
    public var parameters: Parameters?
    
    /// Request header information
    public var headers: Headers
    
    /// Request timeout duration
    public var timeoutInterval: TimeInterval
    
    /// Request Handlers
    /// Any of these interceptors, upon returning the intercepted result, will terminate the iteration and request and return the relevant result.
    public var requestHandlers: [RequestHandleable]
    
    /// Response Handlers
    public var responseHandlers: [ResponseHandleable]
    
    /// Request to end callback
    public var completion: ((Result<Response<Data>, Error>) -> Void)?
    
    /// Data Request built by Alamofire
    public internal(set) var dataRequest: DataRequest?
    
    /// User-defined token
    /// If the user passes in a token when making the request, it will be saved, and when the network request fails, the user can use the token to complete the retry or cancel the operation.
    /// If the user has not set the token, it will be automatically generated when the network is initiated, and saved during the request process. After the request is complete, the request will automatically end.
    /// Requests initiated without setting the token cannot be retried or cancelled
    internal var userDefineToken: String?
    
    /// Execute the request
    /// - Parameter completion: request end callback
    public func execute(completion: @escaping (Result<Response<Data>, Error>) -> Void) {
        
        if let error = requestOptions.validate() {
            completion(.failure(error))
            return
        }
        
        if let result = handle(self) {
            completion(result)
            return
        }
        
        self.completion = completion
        Session.shared.execute(request: self) { [weak self] result in
            guard let sSelf = self else { return }
            let dataResult = sSelf.handle(result)
            guard let resultKey = sSelf.requestOptions.resultKey() else {
                completion(dataResult)
                return
            }
            
            switch dataResult {
            case .success(let response):
                do {
                    guard let data = response.data else {
                        completion(.failure(AsyncNetworkError.ResponseError.parsingKeysFailed(resultKey)))
                        return
                    }
                    
                    let newData = try data.mapping(by: resultKey)
                    let dataResponse = Response<Data>(result: newData,
                                                      data: response.data,
                                                      request: response.request,
                                                      urlRequest: response.urlRequest,
                                                      urlResponse: response.urlResponse,
                                                      metrics: response.metrics,
                                                      serializationDuration: response.serializationDuration)
                    completion(.success(dataResponse))
                    
                } catch {
                    completion(.failure(error))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
        
    /// Intercept requests
    /// - Parameter request: request instance
    /// - Returns: The result after intercepting the request
    private func handle(_ request: Request) -> Result<Response<Data>, Error>? {
        for handler in requestHandlers {
            if let result = handler.handle(request) {
                return result
            }
        }
        return nil
    }
    
    /// Intercept the callback of request results
    /// - Parameter response: request result
    /// - Returns: Intercepts the request response and returns the result
    private func handle(_ response: Result<Response<Data>, Error>) -> Result<Response<Data>, Error> {
        var result: Result<Response<Data>, Error> = response
        for handle in responseHandlers {
            if let callBackResult = handle.handle(result) {
                result = callBackResult
            }
            
            if case .failure(_) = result {
                return result
            }
        }
        
        return result
    }
    
    deinit {
        print(self)
        print("Request deinit")
    }
}
