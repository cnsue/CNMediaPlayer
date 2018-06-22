//
//  ViewController.swift
//  CNMedia
//
//  Created by scn孙长宁 on 2018/6/20.
//  Copyright © 2018年 scn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let vies = CNPlayerView.init(frame: CGRect.init(x: 0, y: 0, width: CNConstant.screenWidth, height: CNConstant.Height.banner))
        
        self.view.addSubview(vies)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

