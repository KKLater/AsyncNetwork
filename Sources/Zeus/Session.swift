//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/7/1.
//

import Foundation
import Alamofire

public class Session {
    
    public static let shared = Session()

    public func cancel(for cancelToken: String) {
        var requests = self.requests
        if let request = requests[cancelToken] {
            request.cancel()
            requests.removeValue(forKey: cancelToken)
            self.requests = requests
        }
    }
    
    public func cancelAll() {
        var requests = self.requests

        sessionManager.cancelAllRequests()
        requests.removeAll()
        self.requests = requests
    }
    
    
    private var requests = [String: DataRequest]()
    
    private var sessionManager: Alamofire.Session
    
    private init() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        sessionManager = Alamofire.Session(configuration: config)
    }
    
    public func execute(request: Zeus.Request, completionHandler: @escaping (Result<Response<Data>, Error>) -> Void)  {
        
        
        let tUrl = request.url
        let tMethod = method(request.method)
        let tParameters = request.parameters
        let tHeader = HTTPHeaders(request.headers)
        
 
        /// 发起网络请求
        let afRequest = sessionManager
            .request(tUrl, method: tMethod, parameters: tParameters, headers: tHeader, requestModifier: { aRequest in
                aRequest.timeoutInterval = request.timeoutInterval
            })
            .validate()
            .responseData { [weak self] dataResponse in
                guard let sSelf = self else { return }
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
                case let .failure(error):
                    completionHandler(.failure(error))
                }
                
         
                sSelf.cancel(for: request.cancelToken)
            }
        
        save(request: afRequest, for: request.cancelToken)
    }
    
    func save(request: DataRequest, for cancelToken: String) {
        var requests = self.requests
        if requests[cancelToken] != nil {
            return
        }
        requests[cancelToken] = request
        self.requests = requests
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
