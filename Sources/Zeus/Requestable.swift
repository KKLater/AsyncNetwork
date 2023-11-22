//
//  File.swift
//  
//
//  Created by 罗树新 on 2023/11/14.
//

import Foundation

public protocol Requestable: JSONEncodable {
            
    /// 请求地址基础信息
    ///
    ///     https://:scheme
    ///
    func baseUrl() -> String
    
    /// 请求路径
    ///
    ///     /v1/get
    func path() -> String
    
    /// 请求方法
    func method() -> Zeus.Method
    
    /// 超时
    func timeoutInterval() -> TimeInterval
    
    /// 请求header信息
    func header() -> Header?

    /// 请求响应链
    /// 请求发起前,对请求做通用拦截处理。
    /// 其中任何一个拦截器，返回 `Result`，拦截中断。请求直接返回 `Result`。
    /// 如果需要请求继续，返回 `nil`
    ///
    /// - Parameter request: 需要做处理的请求
    func requestHandlers() -> [RequestHandleable]
    
    /// 请求结果处理响应链
    /// 请求响应后，对请求结果的拦截处理。
    /// 其中拦截器，返回 `Result`，如果为 `success`，后续拦截器会迭代 新的 `Result`。如果返回 `failure`，迭代终止。
    ///
    /// - Parameter response: 请求响应
    func responseHandlers() -> [ResponseHandleable]

    /// 请求发起前的校验
    func validate() -> Error?
    
    /// 请求参数
    /// 默认使用数据对象, json encode 序列化后，作为参数
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
    ///     /* 其他配置 */
    /// }
    ///
    /// // 请求
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
    /// - Returns: 请求参数
    func parameters() -> Parameters
    
    /// 配置请求结果解析 key
    /// 配置时，按照 key 做解析处理。多层 `key` 需要使用 `.` 拼接。不做配置，全部作为返回结果。默认：nil
    /// - Note:
    ///
    /// 1. 单层 `key`
    /// 服务返回数据：
    /// ```json
    /// {
    ///     "respCode": 0,
    ///     "respData": {
    ///         "name":"KK",
    ///         "id": "112"
    ///     }
    /// }
    /// ```
    /// `resultKey` 配置:
    /// ```swift
    /// func resultKey() -> String? {
    ///     return "respData"
    /// }
    /// ```
    /// 数据返回解析内容:
    /// ```json
    /// {
    ///     "name":"KK",
    ///     "id": "112"
    /// }
    /// ```
    ///
    /// 2. 多层 `key`
    /// 服务返回数据:
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
    /// `resultKey` 配置:
    /// ```swift
    /// func resultKey() -> String? {
    ///     return "respData.contents"
    /// }
    /// ```
    /// 数据返回解析内容:
    /// ```json
    /// {
    ///     "name":"KK",
    ///     "id": "112"
    /// }
    /// ```
    ///
    /// - Returns: 请求结果解析key。
    func resultKey() -> String?
    
    /// 请求参数配置key
    ///
    /// - Note:
    /// 对象类：
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
    /// 未配置 `requestKey` 时，请求参数配置为：
    /// ```ssh
    /// id=112&token=s_token_112
    /// ```
    ///
    /// 配置 `requestKey` :
    ///
    /// ```swift
    /// func requestKey() -> String? {
    ///     return "contents"
    /// }
    /// ```
    ///
    /// 请求参数配置：
    ///
    /// ```shell
    /// contents=%7B%22id%22%3A%22112%22%2C%22token%22%3A%22s_token_112%22%7D
    /// ```
    ///
    /// - Returns: 请求参数配置。配置后，对象解析数据参数，会配置到该 `key`，重组为请求数据参数。默认: nil
    ///
    func requestKey() -> String?
}

public extension Requestable {
    /// 超时
    func timeoutInterval() -> TimeInterval { 20 }

    /// 请求header信息
    func header() -> Header? { nil }

    /// 请求响应链
    func requestHandlers() -> [RequestHandleable] { [] }
        
    /// 请求结果处理响应链
    func responseHandlers() -> [ResponseHandleable] { [] }

    /// 请求发起前的校验
    func validate() -> Error? { nil }
        
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
    
    
    func resultKey() -> String? {
        return nil
    }
    
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
    
    /// 请求二进制数据
    /// `token` 请求过程中，临时存储使用。请求过程中，可以依据 `token` 取消请求。
    /// 
    ///
    /// - Parameters:
    ///   - token: 请求 token
    ///   - completion: 请求结果回调
    func responseData(token: String? = nil, completion: @escaping (Result<Response<Data>, Error>) -> Void) {
        let request = Request(requestOptions: self, token: token)
        request.execute(completion: completion)
    }
    
    func responseJson(token: String? = nil, completion: @escaping (Result<Response<Any>, Error>) -> Void) {
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

/// Connect 请求协议
public protocol Connectable: Requestable {}
public extension Connectable {
    func method() -> Zeus.Method { .connect }
}

/// Delete 请求协议
public protocol Deletable: Requestable {}
public extension Deletable {
    func method() -> Zeus.Method { .delete }
}

/// Get 请求协议
public protocol Getable: Requestable {}
public extension Getable {
    func method() -> Zeus.Method { .get }
}

/// Head 请求协议
public protocol Headable: Requestable {}
public extension Headable {
    func method() -> Zeus.Method { .head }
}

/// Options 请求协议
public protocol Optionsable: Requestable {}
public extension Optionsable {
    func method() -> Zeus.Method { .options }
}

/// Patch 请求协议
public protocol Patchable: Requestable {}
public extension Patchable {
    func method() -> Zeus.Method { .patch }
}

/// Post 请求协议
public protocol Postable: Requestable {}
public extension Postable {
    func method() -> Zeus.Method { .post }
}

/// Put 请求斜体
public protocol Putable: Requestable {}
public extension Putable {
    func method() -> Zeus.Method { .put }
}

/// trace 请求斜体
public protocol Traceable: Requestable {}
public extension Traceable {
    func method() -> Zeus.Method { .trace }
}
