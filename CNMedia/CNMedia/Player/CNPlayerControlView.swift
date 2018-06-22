//
//  CNPlayerControlView.swift
//  CNMedia
//
//  Created by lisue on 2018/6/22.
//  Copyright © 2018年 scn. All rights reserved.
//【播放容器,界面布局】

import UIKit


class CNPlayerControlView: UIView {
    
    // bottomView
    var bottomToolBarView = UIView()
    var bottomToolBarBg = UIView()
    
    // 滑杆
    var videoSlider = ASValueTrackingSlider()
    // 是否拖拽slider控制播放进度
    var isDragged: Bool = false
    
    // 视频总时长label
    var totalTimeLabel = UILabel()
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
        makeSubViewsConstraints()
        addKVO()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
        makeSubViewsConstraints()
        addKVO()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    //UI 初始化
    fileprivate func initUI(){
        
        let bottomToolBarFrame = CGRect(x: 0, y: 0, width: CNConstant.screenHeight, height: 44)
        bottomToolBarBg.addGradientLayer(frame: bottomToolBarFrame, isTop: false)
         self.addSubview(self.bottomToolBarView)
        
        self.bottomToolBarView.addSubview(self.bottomToolBarBg)
        
        videoSlider.popUpViewCornerRadius = 0.0;
        videoSlider.popUpViewColor = UIColor(red: 19, green: 19, blue: 9, alpha: 1)
        //rgba(19, 19, 9, 1)
        videoSlider.popUpViewArrowLength = 8
        videoSlider.setThumbImage(UIImage(named: "video_slider"), for: .normal)
        videoSlider.maximumValue = 1
        videoSlider.minimumTrackTintColor = UIColor.green
        videoSlider.maximumTrackTintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        // slider开始滑动事件
        videoSlider.addTarget(self, action: #selector(progressSliderTouchBegan), for: .touchDown)
        // slider滑动中事件
        videoSlider.addTarget(self, action: #selector(progressSliderValueChanged), for: .valueChanged)
        // slider结束滑动事件
        videoSlider.addTarget(self, action: #selector(progressSliderTouchEnded), for:  [UIControlEvents.touchUpInside, .touchCancel, .touchUpOutside])
        
        let sliderTap = UITapGestureRecognizer(target: self, action: #selector(tapSliderAction))
        videoSlider.addGestureRecognizer(sliderTap)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer))
        panRecognizer.delegate = self
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delaysTouchesBegan = true
        panRecognizer.delaysTouchesEnded = true
        panRecognizer.cancelsTouchesInView = true
        videoSlider.addGestureRecognizer(panRecognizer)
        self.bottomToolBarView.addSubview(self.videoSlider)
//        self.bottomToolBarView.backgroundColor = UIColor.yellow
//        self.backgroundColor = UIColor.orange
    }
    
    // 添加子控件的约束
    func makeSubViewsConstraints(){
        self.bottomToolBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(44)
        }
        
        self.videoSlider.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
        
    }
    
    fileprivate func addKVO(){
        // app退到后台
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        // app进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        self.listeningRotating()
        self.onDeviceOrientationChange()
    }
    
}

extension CNPlayerControlView{
    // 监听设备旋转通知
    @objc func listeningRotating() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // 屏幕方向发生变化会调用这里
    @objc func onDeviceOrientationChange() {
        
        
    }
    
    @objc func setOrientationLandscapeConstraint() {
        
        
    }
    
    // 设置竖屏的约束
    func setOrientationPortraitConstraint() {
        
        
    }
    
    // 应用退到后台
    @objc func appDidEnterBackground() {
        
    }
    
    // 应用进入前台
    @objc func appDidEnterPlayground() {
        
    }
    
    // 不做处理，只是为了滑动slider其他地方不响应其他手势
    @objc func panGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        
    }
    
    @objc func progressSliderTouchBegan(_ sender: ASValueTrackingSlider) {
     
        self.videoSlider.popUpView.isHidden = true
        
    }
    
    @objc func progressSliderValueChanged(_ sender: ASValueTrackingSlider) {
       
    }
    
    @objc func progressSliderTouchEnded(_ sender: ASValueTrackingSlider) {
      
    }
    
    // UISlider TapAction
    @objc func tapSliderAction(_ tap: UITapGestureRecognizer) {
        if let slider = tap.view as? UISlider {
            let point: CGPoint = tap.location(in: slider)
            let length: CGFloat = slider.frame.size.width
            
            // 视频跳转的value
            let tapValue: CGFloat = point.x / length
            
//            将数值传到当前所在的vc里
        }
    }
}

extension CNPlayerControlView: UIGestureRecognizerDelegate {
    
    // slider滑块的bounds
    func thumbRect() -> CGRect {
        let bounds = self.videoSlider.bounds
        let tRect = self.videoSlider.trackRect(forBounds: self.videoSlider.bounds)
        let val = self.videoSlider.value
        return self.videoSlider.thumbRect(forBounds: bounds, trackRect: tRect, value: val)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let rect = self.thumbRect()
        let point = touch.location(in: self.videoSlider)
        
        if let _ = touch.view as? UISlider {
            // 如果在滑块上点击就不响应pan手势
            if ((point.x <= rect.origin.x + rect.size.width) && (point.x >= rect.origin.x)) {
                return false
            }
        }
        
        return true
    }
    
}

