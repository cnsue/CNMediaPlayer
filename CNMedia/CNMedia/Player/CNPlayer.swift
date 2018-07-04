//
//  CNPlayer.swift
//  CNMedia
//
//  Created by lisue on 2018/7/4.
//  Copyright © 2018年 scn. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

@objc protocol CNPlayerDelegate {
    /** 获取视频总时长 */
    func player(_ player: CNPlayer, itemTotal time: CMTime)
    /** 获取视频失败 */
    func player(_ player: CNPlayer,  failure: Error)
    
    /** 播放器状态改变 */
    func player(_ player: CNPlayer, isPlaying: Bool)
    
    /** 视频播放结束 */
    func player(_ player: AVPlayer, willEndPlayAt item: AVPlayerItem)
    
    /** 已经加载的缓存 */
    func player(_ player: AVPlayer, loadedCacheDuration duration: CMTime)
    
    /** 当缓冲是空的时候 */
    func player(_ player: AVPlayer,bufferEmpty: Bool)
    
    /** 当缓冲好的时候 */
    func player(_ player: AVPlayer,bufferSccuess: Bool)
    
   
}

class CNPlayer: AVPlayer{

    weak var delegate: CNPlayerDelegate?
    
    deinit {
        
        removeObserverItem(with: currentItem)
        removeNotificationItem(with: currentItem)
        debugPrint("---LYPlayer结束了---")
    }
    
    public override init() { super.init() }
    
    public override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        addObserverItem(with: item)
        addNotificationItem(with: item)
    }
}

extension CNPlayer{
    // 播放
    open override func play() {
        super.play()
    }
    
    // 暂停
    open override func pause() {
        super.pause()
    }
    
    // 停止
    open func stop() {
        // 保存播放进度
        savePlayTime()
        
        currentItem?.seek(to: kCMTimeZero)
        pause()
        
        currentItem?.cancelPendingSeeks()
        currentItem?.asset.cancelLoading()
        
        removeObserverItem(with: currentItem)
        removeNotificationItem(with: currentItem)
    }
    // 是否正在播放
    open var isPlaying: Bool {
        if #available(iOS 10, *) {
            return timeControlStatus == .playing
        } else {
            return rate != 0.0
        }
    }
    
    // 重新播放新的item
    open override func replaceCurrentItem(with item: AVPlayerItem?) {
        // currentItem
        // item
        super.replaceCurrentItem(with: item)
        addObserverItem(with: item)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath! {
        case "status":
            // 状态改变时调用
            if self.currentItem?.status == .readyToPlay{
                // 准备播放
                debugPrint("准备播放")
                delegate?.player(self, itemTotal: currentItem!.duration)
            }else if self.currentItem?.status == .failed{
                let error = NSError.init(domain: "播放失败", code: 400, userInfo: nil)
                
                delegate?.player(self, failure: error)
            }
        case "loadedTimeRanges":
            // 缓存进度的改变时调用
            // 获取缓冲区域
            guard let timeRange = currentItem?.loadedTimeRanges.first?.timeRangeValue else {
                return
            }
            
            delegate?.player(self, loadedCacheDuration: timeRange.duration)
        case "playbackBufferEmpty":
            // 播放区域缓存为空时调用
            debugPrint("播放区域缓存为空时调用")
            delegate?.player(self, bufferEmpty: true)
        // TODO: 通知代理状态
        case "playbackLikelyToKeepUp":
            // 缓存可以播放的时候调用
            debugPrint("缓存可以播放的时候调用")
            delegate?.player(self, bufferSccuess: true)
        default:
            break
        }
    }
}

// MARK: - FUNC
extension CNPlayer {
    
    /**
     *  计算缓冲进度
     *  @return 缓冲进度
     */
    func availableDuration() -> TimeInterval? {
        if let loadedTimeRanges: [NSValue] = self.currentItem?.loadedTimeRanges,
            let first = loadedTimeRanges.first {
            // 获取缓冲区域
            let timeRange: CMTimeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSeconds
            return result
        }
        return nil
    }
    
    /** 保存播放时间位置 */
    public func savePlayTime() {
        let urlAsset = currentItem?.asset as? AVURLAsset
        guard let urlString = urlAsset?.url.absoluteString else { return }
        guard let currentSeconds = currentItem?.currentTime().seconds else { return }
        // 保存当前播放的时间（秒）
        UserDefaults.standard.set(currentSeconds, forKey: urlString)
    }
    
    /** 继续上一次时间播放 */
    public func playLastTime() {
        let urlAsset = currentItem?.asset as? AVURLAsset
        guard let urlString = urlAsset?.url.absoluteString else { return }
        let lastPlaySeconds = UserDefaults.standard.double(forKey: urlString)
        let time = CMTime(seconds: lastPlaySeconds, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC))
        // 跳到上次记录的时间点播放
        seek(to: time) { (success) in
            super.play()
        }
    }
}

// MARK: - AVPlayerItem Observer
extension CNPlayer {
    // 添加观察者
    fileprivate func addObserverItem(with item: AVPlayerItem?) {
        debugPrint(currentItem!)
        // 观察播放状态
        item?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // 观察已经加载完的时间范围
        item?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        // seekToTime后，缓冲数据为空，而且有效时间内数据无法补充，播放失败
        item?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        
        //seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        item?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    // 移除监听
    fileprivate func removeObserverItem(with item: AVPlayerItem?) {
        item?.removeObserver(self, forKeyPath: "status", context: nil)
        item?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        item?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        item?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
    }
}

// MARK: - AVPlayerItem Notification
extension CNPlayer {
    // 添加播放项目通知
    fileprivate func addNotificationItem(with item: AVPlayerItem?) {
        // 添加视频播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime_notification), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        // 添加视频异常中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled_notification), name: Notification.Name.AVPlayerItemPlaybackStalled, object: item)
    }
    
    // 移除播放项目通知
    fileprivate func removeNotificationItem(with item: AVPlayerItem?) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemPlaybackStalled, object: item)
    }
}

extension CNPlayer {
    
    // 视频播放结束
    @objc func didPlayToEndTime_notification() {
       debugPrint("播放结束")
        stop()
        
        // 通知代理播放结束
        if let item = currentItem {
            delegate?.player(self, willEndPlayAt: item)
        }
    }
    
    // 视频异常中断
    @objc func playbackStalled_notification() {
        debugPrint("异常中断")
    }
    
}
