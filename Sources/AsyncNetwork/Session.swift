//
//  Session.swift
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

public class Session {
    
    public static let shared = Session()
 
    private var sessionManager: Alamofire.Session
    
    private init() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        sessionManager = Alamofire.Session(configuration: config)
    }
    
    public func execute(request: AsyncNetwork.Request, completionHandler: @escaping (Result<Response<Data>, Error>) -> Void)  {
        
        
        let tUrl = request.url
        let tMethod = method(request.method)
        let tParameters = request.parameters
        let tHeader = HTTPHeaders(request.headers)
        
 
        let afRequest = sessionManager
            .request(tUrl, method: tMethod, parameters: tParameters, headers: tHeader, requestModifier: { aRequest in
                aRequest.timeoutInterval = request.timeoutInterval
            })
            .validate()
            .responseData { dataResponse in
                let data = dataResponse.data
                let urlRequest = dataResponse.request
                let urlResponse = dataResponse.response
                let metrics = dataResponse.metrics
                let serializationDuration = dataResponse.serializationDuration
                switch dataResponse.result {
                case let .success(result):
                    let response = Response(result: result,
                                            data: data,
                                            request: request,
                                            urlRequest: urlRequest,
                                            urlResponse: urlResponse,
                                            metrics: metrics,
                                            serializationDuration: serializationDuration)
                    completionHandler(.success(response))
                    RequestManager.shared.cancelRequest(for: request.token)
                case let .failure(error):
                    completionHandler(.failure(error))
                    guard let token = request.userDefineToken else { return }
                    RequestManager.shared.cancelRequest(for: token)
                }
            }
        request.dataRequest = afRequest
        RequestManager.shared.save(request: request, for: request.token)
    }
    
    
    private func method(_ method: Method) -> HTTPMethod {
        var m: HTTPMethod = .get
        switch method {
        case .connect:
            m = .connect
        case .delete:
            m = .delete
        case .get:
            m = .get
        case .head:
            m = .head
        case .options:
            m = .options
        case .patch:
            m = .patch
        case .post:
            m = .post
        case .put:
            m = .put
        case .trace:
            m = .trace
        }
        return m
    }
}
extension Session {
    func cancelAll() {
        sessionManager.cancelAllRequests()
    }
}
