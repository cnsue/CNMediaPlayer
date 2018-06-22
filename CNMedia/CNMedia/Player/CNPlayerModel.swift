//
//  CNPlayerModel.swift
//  CNMedia
//
//  Created by lisue on 2018/6/22.
//  Copyright © 2018年 scn. All rights reserved.
//

import UIKit

// 播放器的几种状态
public enum CNPlayerState: Int {
    case beginToPlay        // 开始播放
    case failed             // 播放失败
    case buffering          // 缓冲中
    case playing            // 播放中
    case stopped            // 停止播放
    case pause              // 暂停播放
}

// 播放器控制面板的几种状态
public enum CNPlayerControlState: Int {
    case waitForRequest     // 请求服务中
    case allowToPlay        // 允许正常播放(某一课程)
    case withoutWiFi        // 非WiFi网络
    case networkInterruption// 无网络
    case experienceUser     // 体验账号用户
}

// 枚举值，包含水平移动方向和垂直移动方向
public enum CNPanDirection: Int {
    case horizontalMoved    // 横向移动
    case verticalMoved      // 纵向移动
}

class CNPlayerModel: NSObject {
    //视频Id
    var videoId: String = ""
    
    //视频标题
    var title: String = ""
    
    //视频URL
    var videoURL: URL!
    
    //视频封面本地图片
    var placeholderImage: UIImage?
    
    //视频封面网络图片url, 如果和本地图片同时设置，则忽略本地图片，显示网络图片
    var placeholderImageURLString: String?
    
    //视频分辨率
    var resolutionDic = [String : Any]()
    
    //从n秒开始播放视频(默认0)
    var seekTime: Int = 0
}


