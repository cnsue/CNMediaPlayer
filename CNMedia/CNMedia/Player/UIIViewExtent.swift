//
//  UIIViewExtent.swift
//  CNMedica
//
//  Created by lisue on 2018/6/20.
//  Copyright © 2018年 lisue. All rights reserved.
//

import UIKit

extension UIView {
    /**
     * 获取变换的旋转角度
     *
     * @return 角度
     */
    func getTransformRotationAngle() -> CGAffineTransform {
        // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
        let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        // 根据要进行旋转的方向来计算旋转的角度
        if (orientation == UIInterfaceOrientation.portrait) {
            return CGAffineTransform.identity
        } else if (orientation == UIInterfaceOrientation.landscapeLeft){
            return CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        } else if(orientation == UIInterfaceOrientation.landscapeRight){
            return CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        return CGAffineTransform.identity
    }
    
}

extension UIView {
    
    //颜色渐变
    func addGradientLayer(frame: CGRect, isTop: Bool) {
        let colorA = UIColor(white: 0.0, alpha: 0.6).cgColor
        let colorB = UIColor.clear.cgColor
        
        let gradientColors = isTop ? [colorA, colorB] : [colorB, colorA]
        let gradientLocations: [NSNumber] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
