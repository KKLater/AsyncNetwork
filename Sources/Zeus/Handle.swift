//
//  Handleable.swift
//  RRCNetwork
//
//  Created by 罗树新 on 2020/10/2.
//

import Foundation

public protocol Handleable {}

public protocol RequestHandleable {
    
    /// 请求发起前的处理
    /// 返回 `Result`，拦截中断。请求直接返回 `Result`。
    /// 如果需要请求继续，返回 `nil`
    ///
    /// - Parameter request: 需要做处理的请求
    func handle(_ request: Request) -> Result<Response<Data>, Error>?
}

public protocol ResponseHandleable {
    
    /// 请求响应的处理
    /// 返回 `Result`，如果为 `success`，后续拦截器会迭代 新的 `Result`。如果返回 `failure`，迭代终止。
    ///
    /// - Parameter response: 请求响应
    func handle(_ response: Result<Response<Data>, Error>) -> Result<Response<Data>, Error>?
}
