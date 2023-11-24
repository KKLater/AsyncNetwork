//
//  Reachability.swift
//  
//
//  Created by 罗树新 on 2023/7/5.
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

public struct Reachability {
    /// Current network reachability status
    public static var netType: String? {
        guard let reachabilityManager = NetworkReachabilityManager.default else { return nil }
        
        if reachabilityManager.isReachableOnCellular {
            return "4G"
        }
        
        if reachabilityManager.isReachableOnEthernetOrWiFi {
            return "WiFi"
        }
        
        return nil
    }
    
    /// Is the current network is in a connected state
    public static var isReachable: Bool {
        return NetworkReachabilityManager.default?.isReachable ?? false
    }
}
