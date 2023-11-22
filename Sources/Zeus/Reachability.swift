//
//  Reachability.swift
//  
//
//  Created by 罗树新 on 2023/7/5.
//

import Foundation
import Alamofire

public struct Reachability {
    /// 当前网络状态
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
    
    public static var isReachable: Bool {
        return NetworkReachabilityManager.default?.isReachable ?? false
    }
}
