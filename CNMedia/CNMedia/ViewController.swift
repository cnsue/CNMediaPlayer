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
        
        view.addSubview(playerView)
        
        playerView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(100)
            make.left.right.equalTo(view)
            make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
    }
    
    lazy var playerView: CNPlayerView = {
       
        let playerView = CNPlayerView(playerModel: self.playerModel)
        
        return playerView
    }()
    
    lazy var playerModel:CNPlayerModel = {
        let playerModel = CNPlayerModel()
        let path = Bundle.main.path(forResource: "Thor", ofType: ".mp4")
        let url = URL(fileURLWithPath: path!)
        
        playerModel.videoURL = url
        playerModel.title = "Thor"
        
        return playerModel
        
    }()
    
    @IBAction func play(_ sender: Any)
    {
        playerView.play()
    }
    
    @IBAction func stop(_ sender: Any)
    {
        playerView.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

