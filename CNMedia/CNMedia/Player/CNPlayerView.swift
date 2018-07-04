//
//  CNPlayerView.swift
//  CNMedia
//
//  Created by lisue on 2018/6/22.
//  Copyright © 2018年 scn. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Alamofire
import SnapKit

public enum Orientation: Int {
    /** 横屏 */
    case horizontal
    /** 竖屏 */
    case vertical
}

class CNPlayerView: UIView {
    // 是否已授权在非WiFi环境下播放视频
    static var canPlayWithoutWiFi: Bool = false
    // 播放属性
    fileprivate var player: CNPlayer?
    fileprivate var urlAsset: AVURLAsset?
    // playerLayer
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var timeObserve: Any!
    
    // 滑杆
    var volumeViewSlider: UISlider?
  
    // 记录上次播放的位置
    var seekTime: Int = 0
   
    //当前播放的位置
    var currentPlayTime: Int = 0
    
    // 用来保存快进的总时长
    var sumTime: CGFloat = 0.0
    
    // 是否自动播放
    var isAutoPlay: Bool = false
    // 静音（默认为false）
    var isMute: Bool = false
    // 是否在调节音量
    var isVolume: Bool = false
    
    // 是否被用户暂停
    var isPauseByUser: Bool = false
    
    // 定义一个实例变量，保存枚举值
    var panDirection: CNPanDirection = .horizontalMoved
    
    // 是否允许播放
    var isAllowPlay: Bool = true
    // 是否播放本地文件
    var isLocalVideo: Bool = false
    
    var videoURL: URL?
    
    final var verticalFrame: CGRect!
    
    var reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown {
        
        didSet {
            if reachabilityStatus != oldValue {
                
                guard playerControlState == .networkInterruption ||
                    playerControlState == .withoutWiFi ||
                    playerControlState == .allowToPlay else {
                        
                        return
                }
                
                if reachabilityStatus == .notReachable &&
                    isAllowPlay && self.state == .buffering {
                    
                    self.playerControlState = .networkInterruption
                    self.isAllowPlay = false
                    self.pause()
                    
                }  else if reachabilityStatus == .reachable(.wwan) && isAllowPlay {
                    
                    if !CNPlayerView.canPlayWithoutWiFi {
                        self.playerControlState = .withoutWiFi
                        self.isAllowPlay = false
                        self.pause()
                    }
                    
                } else if reachabilityStatus == .reachable(.ethernetOrWiFi) && !isAllowPlay {
                    
                    self.playerControlState = .allowToPlay
                    self.isAllowPlay = true
                    self.play()
                }
            }
        }
    }
    
    var playerControlState: CNPlayerControlState = .allowToPlay {
        didSet {
            if playerControlState != .allowToPlay {
                self.pause()
                self.state = .pause
            }
            //将状态传给 控制器view
        }
    }
    
    // 播放器的几种状态
    var state: CNPlayerState = .beginToPlay {
        didSet {
            // 控制菊花显示、隐藏 代码写
           
        
            if (state == .playing || state == .buffering) {
                // 隐藏占位图 代码写
            
                
            } else if (state == .failed) {
                if let error = self.playerItem?.error as NSError? {
                    //代码写
                }
            }
        }
    }
    
    open var playerItem: AVPlayerItem? {
        
        didSet {
            self.player?.replaceCurrentItem(with: playerItem)
        }
    }
    
    fileprivate var _imageGenerator: AVAssetImageGenerator!
    var imageGenerator: AVAssetImageGenerator! {
        get {
            if let asset = self.urlAsset, _imageGenerator == nil {
                _imageGenerator = AVAssetImageGenerator(asset: asset)
            }
            return _imageGenerator
        }
        
        set { }
    }
    
    
    private var _plyContrlView: CNPlayerControlView?
    var plyControlView: CNPlayerControlView? {
        get {
            return _plyContrlView
        }
        set {
            guard _plyContrlView == nil else {
                return
            }
            
            _plyContrlView = newValue
            self.addSubview(_plyContrlView!)
            _plyContrlView?.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets.zero)
            }
        }
    }
    
//    var model: CNPlayerModel? {
//        didSet{
//            if let aModel = model {
//
//            }
//        }
//    }
    
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
//        configPlayer()
        
        let defaultControlView = CNPlayerControlView()
        self.plyControlView = defaultControlView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        configPlayer()
        
    }
    // 指定初始化方法，必须指定播放model 开初始化相应资源
    public convenience init(playerModel:CNPlayerModel) {
        self.init(frame: .zero)
        
        self.videoURL = playerModel.videoURL
        configPlayer()
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        self.playerLayer?.frame = self.bounds
        self.playerLayer?.backgroundColor = UIColor.black.cgColor
        
        // 添加playerLayer 到 self.layer
        if let playerLayer = self.playerLayer {
            self.layer.insertSublayer(playerLayer, at: 0)
        }
    }

    override func draw(_ rect: CGRect) {
        super .draw(rect)
        verticalFrame = frame
        
        addNotificationCenter()
    }
    
    /// 设置Player相关参数
    func configPlayer() {
        
        self.backgroundColor = UIColor.black
        
        if let url = self.videoURL {
            self.urlAsset = AVURLAsset(url: url)
        }
        
        if let asset = self.urlAsset {
            self.playerItem = AVPlayerItem(asset: asset)
        }
        
        // 每次都重新创建Player(替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程)
        self.player = CNPlayer(playerItem: self.playerItem)
        
        // 初始化playerLayer
        self.playerLayer = AVPlayerLayer(player: self.player)
        
        // 此处为默认视频填充模式
        //self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
        // 自动播放
        self.isAutoPlay = true
        
        // 添加播放进度计时器
        self.createTimer()
        
        // 获取系统音量
        self.configureVolume()
        
        // 本地文件不设置HKPlayerStateBuffering状态
        if self.videoURL?.scheme == "file" {
            self.state = .playing;
            self.isLocalVideo = true
            
        } else {
            self.state = .buffering
            self.isLocalVideo = false
        }
        
        // 开始播放
        self.isAllowPlay = true
//        self.play()
        self.player?.rate = 1.0
        self.isPauseByUser = false
    }
    
    
    
    fileprivate func setupFrame(_ orientation: Orientation) {
        if orientation == .horizontal {
            // 横屏
            snp.remakeConstraints({ (make) in
                make.edges.equalTo(superview!)
            })
        } else {
            // 竖屏
            snp.remakeConstraints({ (make) in
                make.left.equalTo(verticalFrame.minX)
                make.top.equalTo(verticalFrame.minY)
                make.width.equalTo(verticalFrame.width)
                make.height.equalTo(verticalFrame.height)
            })
        }
    }
    
    deinit {
        self.playerItem = nil
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
        // 移除time观察者
        if self.timeObserve != nil {
            self.player?.removeTimeObserver(self.timeObserve)
            self.timeObserve = nil
        }
    }
    

}

extension CNPlayerView: CNPlayerDelegate{
    
    typealias completionHandler = ((Bool) -> Void)?
    
    
    /** 获取视频总时长 */
    func player(_ player: CNPlayer, itemTotal time: CMTime){
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        // 添加playerLayer 到 self.layer
        if let playerLayer = self.playerLayer {
            self.layer.insertSublayer(playerLayer, at: 0)
        }
        
        self.state = .playing
        
        // 加载完成后，再添加平移手势
        // 添加平移手势，用来控制音量、亮度、快进快退
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDirectionOnPlayerView))
        panRecognizer.delegate = self
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delaysTouchesBegan = true
        panRecognizer.delaysTouchesEnded = true
        panRecognizer.cancelsTouchesInView = true
        self.addGestureRecognizer(panRecognizer)
        
        // 跳到xx秒播放视频
        if self.seekTime >= 0 {
            self.seekToTime(dragedSeconds: self.seekTime, completionHandler: nil)
        }
        self.player?.isMuted = self.isMute
    }
    
    /** 获取视频失败 */
    func player(_ player: CNPlayer,  failure: Error){
        self.state = .failed
    }
    
    /** 播放器状态改变 */
    func player(_ player: CNPlayer, isPlaying: Bool){
        
    }
    
    /** 视频播放结束 */
    func player(_ player: AVPlayer, willEndPlayAt item: AVPlayerItem){
        
    }
    
    /** 已经加载的缓存 */
    func player(_ player: AVPlayer, loadedCacheDuration duration: CMTime){
        
        // 计算缓冲进度
        if let timeInterval = self.player?.availableDuration(),
            let playerItem = self.playerItem {
            
            let duration: CMTime = playerItem.duration
            let totalDuration: CGFloat = CGFloat(CMTimeGetSeconds(duration))
            //控制器view 状态变化  代码写
        }
    }
    
    /** 当缓冲是空的时候 */
    func player(_ player: AVPlayer,bufferEmpty: Bool){
        // 当缓冲是空的时候
        if (self.playerItem?.isPlaybackBufferEmpty)! {
            self.state = .buffering;
            //self.bufferingSomeSecond()
            
            if self.reachabilityStatus == .notReachable && self.isAllowPlay {
                self.playerControlState = .networkInterruption
                self.isAllowPlay = false
                self.pause()
                
            } else {
                self.bufferingSomeSecond()
                
            }
        }
    }
    
    /** 当缓冲好的时候 */
    func player(_ player: AVPlayer,bufferSccuess: Bool){
        // 当缓冲好的时候
        if ((self.playerItem?.isPlaybackLikelyToKeepUp)! && self.state == .buffering){
            
        }
    }
}

// MARK: 缓冲较差时候
extension CNPlayerView {
    
    /// 缓冲较差时候回调这里
    func bufferingSomeSecond() {
        
        self.state = .buffering
        // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        var isBuffering = false
        
        if isBuffering {
            return
        }
        
        isBuffering = true
        
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        self.player?.pause()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            // 如果此时用户已经暂停了，则不再需要开启播放了
            if self.isPauseByUser {
                isBuffering = false
                return
            }
            
            self.play()
            
            // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
            isBuffering = false
            if (!(self.playerItem?.isPlaybackLikelyToKeepUp)!) {
                self.bufferingSomeSecond()
            }
        })
    }

}

extension CNPlayerView{
    
    func createTimer() {
        
        self.timeObserve = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: nil, using: { [unowned self] (time) in
            
            guard let currentItem = self.playerItem else {
                return
            }
            
            let loadedRanges = currentItem.seekableTimeRanges
            
            if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
                let currentTime: Int = Int(CMTimeGetSeconds(currentItem.currentTime()))
                let totalTime = CGFloat(currentItem.duration.value) / CGFloat(currentItem.duration.timescale)
                
                if totalTime.isNaN {
                    return
                }
                
                let value = CGFloat(CMTimeGetSeconds(currentItem.currentTime())) / totalTime
                
                //设置容器里跨快的状态   代码写
           
            }
        })
    }
    
    /// 获取系统音量
    func configureVolume() {
        
        volumeViewSlider = nil
        
        let volumeView = MPVolumeView()
        
        for subview in volumeView.subviews {
            if (NSStringFromClass(subview.classForCoder) == "MPVolumeSlider") {
                volumeViewSlider = subview as? UISlider
                break
            }
        }
        
        // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error.code)
        }
        
        // 监听耳机插入和拔掉通知
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback), name:
            Notification.Name.AVAudioSessionRouteChange, object: nil)
        
    }
    
    
    /// 耳机插入、拔出事件
    @objc func audioRouteChangeListenerCallback(_ notification: Notification) {
        
        guard let interuptionDic = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        guard  let routeChangeReason: AVAudioSessionRouteChangeReason = interuptionDic[AVAudioSessionRouteChangeReasonKey] as? AVAudioSessionRouteChangeReason else {
            
            return
        }
        
        
        switch (routeChangeReason) {
            
        case .newDeviceAvailable:
            // 耳机插入
            print("newDeviceAvailable")
            
        case .oldDeviceUnavailable:
            // 耳机拔掉
            // 拔掉耳机继续播放
            self.play()
            
        case .categoryChange:
            // called at start - also when other audio wants to play
            print("AVAudioSessionRouteChangeReasonCategoryChange")
            
        default:
            break
        }
    }
    
    
    
    /**
     *  从xx秒开始播放视频跳转
     *
     *  @param dragedSeconds 视频跳转的秒数
     */
    func seekToTime(dragedSeconds: Int, completionHandler: completionHandler) {
        
        if self.player?.currentItem?.status == .readyToPlay {
            
            // seekTime:completionHandler:不能精确定位
            // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
            // 转换成CMTime才能给player来控制播放进度
           
            //转动菊花  代码写
            
            self.player?.pause()
            
            let dragedCMTime = CMTime(value: CMTimeValue(dragedSeconds), timescale: 1)
            
            self.player?.seek(to: dragedCMTime, toleranceBefore: CMTime(value: 1, timescale: 1), toleranceAfter: CMTime(value: 1, timescale: 1), completionHandler: {[unowned self] (finished) in
                
               //停止转动菊花 代码写
                
                // 视频跳转回调
                if completionHandler != nil {
                    completionHandler!(finished)
                }
                
                //处理状态以及界面效果 代码写
           
            })
        }
    }
    
}

extension CNPlayerView{
  
    
    /// 播放
    func play() {
        self.player?.play()
    }
    
    /// 暂停
    func pause() {
        guard (self.plyControlView != nil && self.player != nil) else {
            return
        }
        self.player?.pause()
    }
    
    
    /// 停止播放
    func stop() {
        // player加到控制器上，只有一个player时候
        self.pause()
        
        // 移除原来的layer
        self.playerLayer?.removeFromSuperlayer()
        // 替换PlayerItem为nil
        self.player?.replaceCurrentItem(with: nil)
        // 把player置为nil
        self.imageGenerator = nil
        self.player = nil
        
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
        // 移除time观察者
        if self.timeObserve != nil {
            self.player?.removeTimeObserver(self.timeObserve)
            self.timeObserve = nil
        }
    }
    
}
extension CNPlayerView{
    
    /// pan手势事件
    @objc func panDirectionOnPlayerView(_ pan: UIPanGestureRecognizer) {
        //根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint: CGPoint = pan.location(in: self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint: CGPoint = pan.velocity(in: self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
            
        case .began: // 开始移动
            // 使用绝对值来判断移动的方向
            let x: CGFloat = fabs(velocityPoint.x)
            let y: CGFloat = fabs(velocityPoint.y)
            if (x > y) { // 水平移动
                // 取消隐藏
                self.panDirection = .horizontalMoved
                // 给sumTime初值
                let time: CMTime = self.player!.currentTime()
                self.sumTime = CGFloat(time.value)/CGFloat(time.timescale)
            }
            else if (x < y){ // 垂直移动
                self.panDirection = .verticalMoved
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = true
                } else { // 状态改为显示亮度调节
                    self.isVolume = false
                }
            }
            
        case .changed: // 正在移动
            switch self.panDirection {
            case .horizontalMoved:
                self.horizontalMovedOnPlayerView(velocityPoint.x) // 水平移动的方法只要x方向的值
            case .verticalMoved:
                self.verticalMovedOnPlayerView(velocityPoint.y) // 垂直移动方法只要y方向的值
            }
            
        case .ended: // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch self.panDirection {
                
            case.horizontalMoved:
                self.isPauseByUser = false
                
                if !sumTime.isNaN {
                    self.seekToTime(dragedSeconds: Int(sumTime), completionHandler: nil)
                }
                
                // 把sumTime置空，不然会越加越多
                self.sumTime = 0
                
            case .verticalMoved:
                // 垂直移动结束后，把状态改为不再控制音量
                self.isVolume = false
            }
            
        default:
            break
        }
    }
    
    /// pan垂直移动的方法
    func verticalMovedOnPlayerView(_ value: CGFloat) {
        if self.isVolume {
            self.volumeViewSlider?.value -= Float(value) / 10000
        } else {
            UIScreen.main.brightness -= value / 10000
        }
    }
    
    
    /// pan水平移动的方法
    func horizontalMovedOnPlayerView(_ value: CGFloat) {
        
        // 每次滑动需要叠加时间
        self.sumTime += value / 200
        
        // 需要限定sumTime的范围
        guard let playerItem = self.playerItem else {
            return
        }
        
        let totalTime: CMTime = playerItem.duration
        let totalMovieDuration = CGFloat(totalTime.value)/CGFloat(totalTime.timescale)
        
        if totalMovieDuration.isNaN {
            return
        }
        
        if (self.sumTime > totalMovieDuration) {
            self.sumTime = totalMovieDuration
        }
        
        if (self.sumTime < 0) {
            self.sumTime = 0
        }
        
        var style: Bool = false
        if (value > 0) { style = true }
        if (value < 0) { style = false }
        if (value == 0) { return }
        
        //改变状态 。。。 代码写
    }
    
    
    /**
     *  根据时长求出字符串
     *
     *  @param time 时长
     *
     *  @return 时长字符串
     */
    func durationString(with time: Int) -> String {
        // 获取分钟
        let min = String.init(format: "%02d",  arguments: [time / 60])
        // 获取秒数
        let sec = String.init(format: "%02d",  arguments: [time % 60])
        
        return String.init(format: "%@:%@",  arguments: [min, sec])
    }
    
    
}

//MARK: - UIGestureRecognizerDelegate
extension CNPlayerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if playerControlState != .allowToPlay {
            return false
        }
        
        if touch.view is UIButton {
            return false
        }
        
        if gestureRecognizer is UIPanGestureRecognizer {
            
        }
        
        if gestureRecognizer is UITapGestureRecognizer {
            
        }
        
        if touch.view is UISlider {
            return false
        }
        
        return true
    }
    
}

extension CNPlayerView {
    
    fileprivate func addNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientation), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    fileprivate func removeNotificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // 处理旋转过程中需要的操作
    @objc func orientation(notification: NSNotification) {
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape {
            // 屏幕水平
            setupFrame(.horizontal)
        } else if orientation.isPortrait {
            // 屏幕竖直
            setupFrame(.vertical)
        }
    }
}
