//
//  MainMusicViewController.swift
//  SwiftMusic
//
//  Created by 科文 on 2017/5/3.
//  Copyright © 2017年 科文. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MainMusicViewController: UIViewController,UITabBarDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var miniPlayerButton: UIButton!
    @IBOutlet weak var tabBar: UITabBar!
    
    var nowNum:Int!
    var timer:Timer!
    var musicTalbleVC: MuiscListViewController!
    private var moreVC: UINavigationController!
    
    fileprivate var modalVC :DetailMusicViewController!
    private var animator : ARNTransitionAnimator?
    var musicModel:Music?
    var musicArry:Array<Music>!
 //   var isPlay : Bool!=false
    
    @IBAction func ClickMiniPlayerBtn(_ sender: Any) {
        if self.musicModel != nil {
            self.present(self.modalVC, animated: true, completion: nil)
          //  self.navigationController?.pushViewController(self.modalVC, animated: true)
        }
    }
    
    @IBAction func nextMusicBtn(_ sender: Any) {
        self.nowNum=self.nowNum+1
        if self.nowNum>=self.musicArry.count{
            self.nowNum=0
        }
        if AudioPlayer.nextsong(num: self.nowNum){
           refreashView()
        }
    }
    
    @IBAction func musicPlayBtn(_ sender: Any) {
        let sender=sender as! UIButton
//        if isPlay {
//            AudioPlayer.pause()
//            isPlay=false
//            sender.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
//        }else{
//            AudioPlayer.play()
//            isPlay=true
//            sender.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
//        }
        if AudioPlayer.play(){
            sender.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
        }else{
            sender.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
        }
    }
    
    func setStatusBarBackgroundColor(color : UIColor) {
        let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as? UIView)?.value(forKey: "statusBar") as? UIView
        statusBar?.backgroundColor=color
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let session:AVAudioSession=AVAudioSession.sharedInstance()
        do{
        try session.setCategory(AVAudioSessionCategoryPlayback)
        try session.setActive(true)
        }
        catch{
        }
        
        //1.告诉系统接受远程响应事件，并注册成为第一响应者
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        
        self.modalVC=self.storyboard?.instantiateViewController(withIdentifier: "DetailMusicViewController") as! DetailMusicViewController
        self.modalVC.modalPresentationStyle = .overFullScreen//弹出属性
        self.setupAnimator()
        self.miniPlayerWork()
        self.musicArry=Music.getALL()
        self.tabBar.delegate=self
        self.moreVC = self.storyboard?.instantiateViewController(withIdentifier: "aboutVC") as! UINavigationController
        if self.tabBar.selectedItem == nil {
            
        }
        // Do any additional setup after loading the view.
    }

    func setupAnimator(){
        let animation=MusicPlayerTransitionAnimation(rootVC: self, modalVC: self.modalVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self=self else{ return }//再次强引用
                let modalGestureHandler=TransitionGestureHandler (targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(_self.modalVC.view)
                modalGestureHandler.panCompletionThreshold=15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            }else{
                
                self?.setupAnimator()
            }
        }
        
            let miniPlayerGestureHandler = TransitionGestureHandler(targetVC: self, direction: .top)
            miniPlayerGestureHandler.registerGesture(self.miniPlayerView)
            miniPlayerGestureHandler.panCompletionThreshold=15.0
            
            self.animator=ARNTransitionAnimator(duration: 0.5, animation: animation)
            self.animator?.registerInteractiveTransitioning(.present, gestureHandler: miniPlayerGestureHandler)
            self.modalVC.transitioningDelegate=self.animator
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            let newController = self.musicTalbleVC!
            
            let oldController = childViewControllers.last!
            if newController != oldController {
              //  self.setStatusBarBackgroundColor(color: UIColor.white)
                oldController.willMove(toParentViewController: nil)
                addChildViewController(newController)
                newController.view.frame = oldController.view.frame
                
                //isAnimating = true
                transition(from: oldController, to: newController, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: nil, completion: { (finished) -> Void in
                    oldController.removeFromParentViewController()
                    newController.didMove(toParentViewController: self)                //self.isAnimating = false
                })
            }
        }else{
            let newController = self.moreVC!
            let oldController = childViewControllers.last!
             if newController != oldController {
                self.setStatusBarBackgroundColor(color: UIColor.clear)
                oldController.willMove(toParentViewController: nil)
                addChildViewController(newController)
                newController.view.frame = oldController.view.frame
                transition(from: oldController, to: newController, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromRight, animations: nil, completion: { (finished) -> Void in
                    oldController.removeFromParentViewController()
                    newController.didMove(toParentViewController: self)                //self.isAnimating = false
                })
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Dad2Son" {
           self.musicTalbleVC=segue.destination as! MuiscListViewController
        }
    }
    
    func miniPlayerWork(){
        let musicImg=self.miniPlayerView.viewWithTag(1) as! UIImageView
        let musicName = self.miniPlayerView.viewWithTag(2) as! UILabel
        let musicPlayBtn = self.miniPlayerView.viewWithTag(3) as! UIButton
//        let nextMusicBtn = self.miniPlayerView.viewWithTag(4) as! UIButton
        self.musicTalbleVC.musicPlayByTableViewCell={
          [weak self]  musicNum in self?.musicModel=self?.musicArry[musicNum]
            self?.nowNum=musicNum
            self?.miniPlayerWork()
        }
        if self.musicModel != nil {
            musicName.text=self.musicModel?.musicName
            musicImg.image=UIImage (data: (self.musicModel?.musicimg)!)
            if AudioPlayer.share(model: self.musicModel!){
                self.modalVC.model=musicModel
                if AudioPlayer.isPlaying(){
                    musicPlayBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
                }else{
                    musicPlayBtn.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
                }
            self.musicTalbleVC?.tableVIew.reloadData()
                if self.timer == nil{
                    self.timer=Timer .scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.setBackground), userInfo: nil, repeats: true)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //  self.setStatusBarBackgroundColor(color: UIColor.white)
        //self.timeStop()
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        refreashView()
//        UIApplication.shared.endReceivingRemoteControlEvents()
//        self.resignFirstResponder()
        
    }
    
    override var canBecomeFirstResponder: Bool{
        
        return true
    }
    
    func refreashView(){
        self.musicModel=AudioPlayer.activeSong()
        if self.musicModel != nil {
        DispatchQueue.main.async(execute: {
            
            self.nowNum=(self.musicModel?.musicNum)!-1
            let musicImg=self.miniPlayerView.viewWithTag(1) as! UIImageView
            let musicName = self.miniPlayerView.viewWithTag(2) as! UILabel
            let musicPlayBtn = self.miniPlayerView.viewWithTag(3) as! UIButton
            musicName.text=self.musicModel?.musicName
            musicImg.image=UIImage (data: (self.musicModel?.musicimg)!)
            if AudioPlayer.isPlaying(){
                musicPlayBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
            }else{
                musicPlayBtn.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
            }
            self.musicTalbleVC?.tableVIew.reloadData()
            })
        }
    }

}
extension MainMusicViewController {
    func setBackground() {
        //大标题 - 小标题  - 歌曲总时长 - 歌曲当前播放时长 - 封面
        self.musicModel=AudioPlayer.activeSong()
        var settings = [MPMediaItemPropertyTitle: self.musicModel?.musicName,
                        MPMediaItemPropertyArtist: self.musicModel?.musicAuthor ,
                        MPMediaItemPropertyPlaybackDuration: "\(AudioPlayer.musicDuration())",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: "\(AudioPlayer.currentTime())",MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: UIImage (data: (self.musicModel?.musicimg)!)!)] as [String : Any]
        MPNowPlayingInfoCenter.default().setValue(settings, forKey: "nowPlayingInfo")
        if AudioPlayer.progress() > 0.99 { // 自动播放下一曲 ()后台
                self.nowNum=self.nowNum+1
            if self.nowNum>=self.musicArry.count{
                self.nowNum=0
            }
            if AudioPlayer.nextsong(num: self.nowNum){
                refreashView()
            }
        }
    }
    func timeStop(){
        if timer != nil{
            self.timer.invalidate()
            self.timer=nil
        }
    }
}
extension MainMusicViewController {
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == UIEventType.remoteControl {
            switch event!.subtype {
            case .remoteControlTogglePlayPause:
                 if AudioPlayer.play(){
                }
            case .remoteControlPreviousTrack: // ##  <-  ##
                self.nowNum=self.nowNum-1
                if self.nowNum == -1{
                    self.nowNum=self.musicArry.count - 1
                }
                if AudioPlayer.prevsong(num: self.nowNum){
                    self.musicModel=AudioPlayer.activeSong()
                    refreashView()
                }

            case .remoteControlNextTrack: // ## -> ##
                self.nowNum=self.nowNum+1
                if self.nowNum>=self.musicArry.count{
                    self.nowNum=0
                }
                
                if AudioPlayer.nextsong(num: self.nowNum){
                    self.musicModel=AudioPlayer.activeSong()
                    refreashView()
                }
            case .remoteControlPlay: // ## > ##
                if AudioPlayer.play(){
                     let musicPlayBtn = self.miniPlayerView.viewWithTag(3) as! UIButton
                    if AudioPlayer.isPlaying(){
                        musicPlayBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
                    }else{
                        musicPlayBtn.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
                    }
                }else{
                   
                }

            case .remoteControlPause: // ## || ##
               AudioPlayer.pause()
                 let musicPlayBtn = self.miniPlayerView.viewWithTag(3) as! UIButton
               if AudioPlayer.isPlaying(){
                musicPlayBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
               }else{
                musicPlayBtn.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
                }
            default:
                break
            }
        }
    }
}
