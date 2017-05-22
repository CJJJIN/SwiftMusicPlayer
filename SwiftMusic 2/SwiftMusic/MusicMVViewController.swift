//
//  MusicMVViewController.swift
//  SwiftMusic
//
//  Created by 科文 on 2017/5/10.
//  Copyright © 2017年 科文. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class MusicMVViewController: UIViewController,AVPlayerViewControllerDelegate {
    @IBOutlet weak var MVVIew: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var vc : AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path:String=Bundle.main.path(forResource: "[周深]大鱼（电影《大鱼海棠》印象曲）_bd.mp4", ofType: nil)!
        vc = AVPlayerViewController();
        vc.player=AVPlayer.init(url: URL.init(fileURLWithPath: path))
        vc.view.frame = self.MVVIew.bounds
        self.MVVIew.addSubview(vc.view)
//        self.MVVIew.bringSubview(toFront:self.closeButton)
        vc.delegate=self
        vc.player?.play()
//        let avPlayer:AVPlayer=AVPlayer.init(url: URL.init(fileURLWithPath: path))
//        let avLayer : AVPlayerLayer = (AVPlayerLayer.init(player: avPlayer))
//        avLayer.frame=self.MVVIew.bounds
//        self.MVVIew.layer.addSublayer(avLayer)
//
//        avPlayer.play()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func CloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
