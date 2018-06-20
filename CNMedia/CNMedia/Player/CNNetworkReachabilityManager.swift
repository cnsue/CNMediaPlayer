//
//  CNNetworkReachabilityManager.swift
//  CNMedica
//
//  Created by lisue on 2018/6/20.
//  Copyright © 2018年 lisue. All rights reserved.
//【监听网络状态】

import UIKit
import Alamofire

class CNNetworkReachabilityManager: NSObject {
    
    static let shared = CNNetworkReachabilityManager()
    
    var manager: NetworkReachabilityManager?
    
    // 获取网络连接状态
    var status: NetworkReachabilityManager.NetworkReachabilityStatus {
        get {
            return manager?.networkReachabilityStatus ?? .unknown
        }
    }
    
    // 判断网络是否连接
    var isReachable: Bool {
        get {
            return manager?.isReachable ?? false
        }
    }
    
    // 判断 WiFi 是否连接
    var isReachableOnEthernetOrWiFi: Bool {
        get {
            return manager?.isReachableOnEthernetOrWiFi ?? false
        }
    }
    
    
    var listener: NetworkReachabilityManager.Listener?
    
    
    // 判断 无线网络 是否连接
    var isReachableOnWWAN: Bool {
        get {
            return manager?.isReachableOnWWAN ?? false
        }
    }
    
    override init() {
        
    }
    
    deinit {
        manager?.stopListening()
    }
    
    func startListen() {
        if manager == nil {
            manager = NetworkReachabilityManager()
        }
        
        manager?.listener = { [unowned self] (status) in
            debugPrint("Network Status Changed: \(status)")
            
            if self.listener != nil {
                self.listener!(status)
            }
        }
        manager?.startListening()
    }
    
}
