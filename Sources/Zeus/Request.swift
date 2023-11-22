//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/7/1.
//

import Foundation

public class Request {
    public private(set) var requestOptions: any Requestable
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
        self.cancelToken = token ?? UUID().uuidString
    }
    
    public var cancelToken: String
    
    public var url: String
    public var path: String
    public var method: Method
    public var parameters: Parameters?
    public var headers: Headers
    public var timeoutInterval: TimeInterval
    public var requestHandlers: [RequestHandleable]
    public var responseHandlers: [ResponseHandleable]
    
    public var completion: ((Result<Response<Data>, Error>) -> Void)?
    
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
                        completion(.failure(ZeusError.ResponseError.parsingKeysFailed(resultKey)))
                        return
                    }
                    
                    let newData = try data.zeus.mapping(by: resultKey)
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
    
    @discardableResult
    public func retry() -> Bool {
        Session.shared.cancel(for: cancelToken)
        if let completion = completion {
            execute(completion: completion )
            return true
        }
        
        return false
    }
    
    public func cancel() {
        Session.shared.cancel(for: cancelToken)
    }
    
    
    private func handle(_ request: Request) -> Result<Response<Data>, Error>? {
        for handler in requestHandlers {
            if let result = handler.handle(request) {
                return result
            }
        }
        return nil
    }
    
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
