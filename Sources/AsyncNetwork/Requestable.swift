//
//  Requestable.swift
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

/// Request configuration protocol
/// Follow the protocol of the class or struct, implement its related protocol methods. 
/// Its instances can construct Request instances and initiate requests.
/// Generally, a class or struct only supports the completion of one request business.
public protocol Requestable: JSONEncodable {
            
    /// Request address basic information
    ///
    ///     https://:scheme
    ///
    func baseUrl() -> String
    
    /// Request path
    ///
    ///     /v1/get
    func path() -> String
    
    /// Request Method
    func method() -> AsyncNetwork.Method
    
    /// Request timeout configuration
    func timeoutInterval() -> TimeInterval
    
    /// Request header information
    func header() -> Header?

    /// Request response chain
    /// Perform general interception processing on the request before it is initiated.
    /// Any of these interceptors returns a Result to interrupt the request. The request returns directly to the Result.
    /// If you need to request to continue, return nil
    ///
    /// - Parameter request: The request to be processed
    func requestHandlers() -> [RequestHandleable]
    
    /// Request result processing response chain
    /// After the request response, intercept and process the request result.
    /// The interceptor returns a Result, if it is success, the subsequent interceptors will iterate the new Result. If it returns failure, the iteration will terminate.
    ///
    /// - Parameter response: request response
    func responseHandlers() -> [ResponseHandleable]

    /// Verification before request initiation
    func validate() -> Error?
    
    /// Request parameters
    /// Use the data object by default, after serialization with json encode, as the parameter
    ///
    /// ```swift
    /// struct GetRequest: Requestable {
    ///     var id: String
    ///     var name: String
    ///     var city: String
    ///
    ///     init(id: String, name: String, city: String) {
    ///         self.id = id
    ///         self.name = name
    ///         self.city = city
    ///     }
    ///     /* Other Configurations */
    /// }
    ///
    /// // Build a request instance
    /// let request = GetRequest(id: "111", name: "KK", city: "bj")
    ///
    /// let parameters = request.parameters()
    /// /*
    /// {
    ///     "id": "111",
    ///     "name": "KK",
    ///     "city": "bj"
    /// }
    /// */
    /// print(parameters)
    /// ```
    /// - Returns: Request Parameters
    func parameters() -> Parameters
    
    /// Configure the request result parsing key
    /// When configuring, parse according to the key. Multi-level keys need to be concatenated using a`.`. If no configuration is made, all will be returned as the result. Default: `nil`
    /// - Note:
    ///
    /// 1. JSON level with only one layer of key
    /// Service return data:
    /// ```json
    /// {
    ///     "respCode": 0,
    ///     "respData": {
    ///         "name":"KK",
    ///         "id": "112"
    ///     }
    /// }
    /// ```
    /// `resultKey` implementation:
    /// ```swift
    /// func resultKey() -> String? {
    ///     return "respData"
    /// }
    /// ```
    /// Data returned parsing content:
    /// ```json
    /// {
    ///     "name":"KK",
    ///     "id": "112"
    /// }
    /// ```
    ///
    /// 2. key when the JSON hierarchy is multi-level
    /// Service return data
    /// ```json
    /// {
    ///     "respCode": 0,
    ///     "respData": {
    ///         "contents" {
    ///             "name":"KK",
    ///             "id": "112"
    ///         }
    ///     }
    /// }
    /// ```
    /// `resultKey` implementation:
    /// ```swift
    /// func resultKey() -> String? {
    ///     return "respData.contents"
    /// }
    /// ```
    /// Data returned parsing content:
    /// ```json
    /// {
    ///     "name":"KK",
    ///     "id": "112"
    /// }
    /// ```
    ///
    /// - Returns: Resolve the key of the request result.
    func resultKey() -> String?
    
    /// Request parameter configuration key
    ///
    /// - Note:
    /// A Request Example
    /// ```swift
    /// struct GetRequest: Getable, APISession {
    ///     public func path() -> String {
    ///         return "/test/get"
    ///     }
    ///
    ///     var id: String
    ///     var token: String
    ///
    ///     init(id: String, token: String) {
    ///         self.id = id
    ///         self.token = token
    ///     }
    /// }
    ///
    /// let request = GetRequest(id: "112", token: "s_token_112")
    /// request.execute { response in
    ///
    /// }
    /// ```
    ///
    /// When the 'requestKey' is not configured, the request parameter configuration:
    /// ```ssh
    /// id=112&token=s_token_112
    /// ```
    ///
    /// When configuring the 'requestKey', configure the request parameters:
    ///
    /// ```swift
    /// func requestKey() -> String? {
    ///     return "contents"
    /// }
    /// ```
    ///
    /// Request parameter configuration:
    ///
    /// ```shell
    /// contents=%7B%22id%22%3A%22112%22%2C%22token%22%3A%22s_token_112%22%7D
    /// ```
    ///
    /// - Returns: Request parameter configuration. After configuration, the object parsing data parameter will be configured to the key and reorganized into the request data parameter. Default: `nil`
    ///
    func requestKey() -> String?
}

public extension Requestable {
    /// Request timeout configuration
    func timeoutInterval() -> TimeInterval { 20 }

    /// Request header information
    func header() -> Header? { nil }

    /// Request chain
    func requestHandlers() -> [RequestHandleable] { [] }
        
    /// Request response chain
    func responseHandlers() -> [ResponseHandleable] { [] }

    /// Verification before request initiation
    func validate() -> Error? { nil }
        
    /// Request Parameters
    func parameters() -> Parameters {
        guard let requestKey = requestKey() else {
            guard let dic = try? json() as? Parameters else { return [:] }
            return dic
        }
        
        guard let dic = try? json() as? Parameters else {
            return [ requestKey : [:]]
        }
        return [ requestKey : dic]
    }
    
    
    /// Configure the request result parsing key
    func resultKey() -> String? {
        return nil
    }
    /// Request parameter configuration key
    func requestKey() -> String? {
        return nil
    }
}

extension Requestable {
    
    func readPath() -> String {
        return path()
    }
    
    func readUrl() -> String {
        var baseUrl = baseUrl()
        let path = readPath()
        if baseUrl.hasSuffix("/") {
            baseUrl.removeLast()
        }
        
        
        if path.hasPrefix("/") {
            baseUrl.append(path)
        } else {
            baseUrl.append("/\(path)")
        }
        return baseUrl
    }
    

    func readHeaders() -> Headers {
        var headers: Headers = Headers()
        if let sHeader = header() {
            headers.append(sHeader.headers())
        }
        return headers
    }
    
    func readTimeoutInterval() -> TimeInterval {
        return timeoutInterval()
    }
    
    
    func readRequestHandlers() -> [RequestHandleable] {
        return requestHandlers()
    }
    
    func readResponseHandlers() -> [ResponseHandleable] {
        return responseHandlers()
    }
}

public extension Requestable {
    
    /// Request binary data
    /// token is used for temporary storage during the request process. During the request process, you can cancel the request based on the token. When the request fails, you can use the token to retry the request or cancel the request.
    ///
    ///
    /// - Parameters:
    /// - token: request token
    /// - completion: callback for request result
    func responseData(token: String? = nil, completion: @escaping (Result<Response<Data>, Error>) -> Void) {
        let request = Request(requestOptions: self, token: token)
        request.execute(completion: completion)
    }
    
    /// Request JSON data
    /// token is used for temporary storage during the request process. During the request process, you can cancel the request based on the token. When the request fails, you can use the token to retry the request or cancel the request.
    ///
    /// - Parameters:
    ///   - token: request token
    ///   - completion: callback for request result
    func responseJSON(token: String? = nil, completion: @escaping (Result<Response<Any>, Error>) -> Void) {
        let request = Request(requestOptions: self, token: token)
        request.execute { result in
            switch result {
            case .success(let response):
                do {
                    let json = try response.getJson()
                    let jsonResponse = Response<Any>(result: json,
                                                     data: response.data,
                                                     request: response.request,
                                                     urlRequest: response.urlRequest,
                                                     urlResponse: response.urlResponse,
                                                     metrics: response.metrics,
                                                     serializationDuration: response.serializationDuration)
                    completion(.success(jsonResponse))
                } catch {
                    completion(.failure(error))
                    return
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
            
        }
    }
}

public extension Requestable where Self: ResponseDecodable {
    
    /// Request Decodable result data, the request configuration needs to follow the ResponseDecodable protocol and configure the ResponseType
    /// Only requests that conform to the ResponseDecodable protocol can directly obtain decodable data
    /// Token is used for temporary storage during the request process. During the request process, you can cancel the request based on the token. When the request fails, you can use the token to retry the request or cancel the request.
    ///
    /// - Parameters:
    ///   - token: request token
    ///   - completion: callback for request result
    func responseDecodable(token: String? = nil, completion: @escaping (Result<Response<ResponseType>, Error>) -> Void) {
        let request = Request(requestOptions: self, token: token)
        request.execute { result in
            switch result {
            case .success(let response):
                do {
                    let object = try ResponseType.object(from: response.result)
                    let objectResponse = Response<ResponseType>(result: object,
                                                                data: response.data,
                                                                request: response.request,
                                                                urlRequest: response.urlRequest,
                                                                urlResponse: response.urlResponse,
                                                                metrics: response.metrics,
                                                                serializationDuration: response.serializationDuration)
                    completion(.success(objectResponse))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let failure):
                completion(.failure(failure))

            }
                      
        }
    }

}

/// Connect request, the request method is `.connect`
public protocol Connectable: Requestable {}
public extension Connectable {
    func method() -> AsyncNetwork.Method { .connect }
}

/// Delete request, the request method is `.delete`
public protocol Deletable: Requestable {}
public extension Deletable {
    func method() -> AsyncNetwork.Method { .delete }
}

/// Get request, the request method is `.get`
public protocol Getable: Requestable {}
public extension Getable {
    func method() -> AsyncNetwork.Method { .get }
}

/// Head request, the request method is `.head`
public protocol Headable: Requestable {}
public extension Headable {
    func method() -> AsyncNetwork.Method { .head }
}

/// Options request, the request method is `.options`
public protocol Optionsable: Requestable {}
public extension Optionsable {
    func method() -> AsyncNetwork.Method { .options }
}

/// Patch request, the request method is `.patch`
public protocol Patchable: Requestable {}
public extension Patchable {
    func method() -> AsyncNetwork.Method { .patch }
}

/// Post request, the request method is `.post`
public protocol Postable: Requestable {}
public extension Postable {
    func method() -> AsyncNetwork.Method { .post }
}

/// Put request, the request method is `.put`
public protocol Putable: Requestable {}
public extension Putable {
    func method() -> AsyncNetwork.Method { .put }
}

/// Trace request, the request method is `.trace`
public protocol Traceable: Requestable {}
public extension Traceable {
    func method() -> AsyncNetwork.Method { .trace }
}
