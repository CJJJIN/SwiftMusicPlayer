//
//  DetailMusicViewController.swift
//  SwiftMusic
//
//  Created by 科文 on 2017/5/3.
//  Copyright © 2017年 科文. All rights reserved.
//
import MediaPlayer
import UIKit

class DetailMusicViewController: UIViewController {
    @IBOutlet weak var randomPlay: UIButton!
    @IBOutlet weak var backGroundImg: UIImageView!
    @IBOutlet weak var playMusicBtn: UIButton!
    @IBOutlet weak var leftTime: UILabel!
    @IBOutlet weak var rightTime: UILabel!
    @IBOutlet weak var mvButton: UIButton!

    @IBOutlet weak var albumImg: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var nextMusicBtn: UIButton!
    @IBOutlet weak var MusicAuthor: UILabel!
    @IBOutlet weak var MusicName: UILabel!
    @IBOutlet weak var musicProgress: UIProgressView!
    
    
    var nowNum:Int!
    var model : Music!
    var musicArry:Array<Music>!
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicProgress.progress=0 //初始化进度条为0
        // Do any additional setup after loading the view.
    }
    //随机播放按钮
    @IBAction func musicRandomPlay(_ sender: UIButton) {
        if AudioPlayer.musicRandomPlay(){
            sender.setImage(#imageLiteral(resourceName: "randomPlay"), for: .normal)
        }else{
            sender.setImage(#imageLiteral(resourceName: "sequencePlay"), for: .normal)
        }
        
    }
    //播放音乐
    @IBAction func musicPlayBtn(_ sender: Any) {
        let sender=sender as! UIButton
        if AudioPlayer.play(){
            sender.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
        }else{
            sender.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //左上角关闭窗口
    @IBAction func closePlayer(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //播放下一曲方法
    @IBAction func nextTrack(_ sender: Any) {
        self.nowNum=self.nowNum+1
        if self.nowNum>=self.musicArry.count{
            self.nowNum=0
        }
        if AudioPlayer.nextsong(num: self.nowNum){
            self.playMusicBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
            self.timeStop()
            reflashView()
          //  reflashView(num: self.nowNum)
        }
    }
    //停止计时器方法
    func timeStop(){
        if timer != nil{
            self.timer.invalidate()
            self.timer=nil
        }
    }
    // 上一曲
    
    @IBAction func prevTrack(_ sender: Any) {
        self.nowNum=self.nowNum-1
        if self.nowNum == -1{
            self.nowNum=self.musicArry.count - 1
        }
        if AudioPlayer.prevsong(num: self.nowNum){
            self.playMusicBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
           // reflashView(num: self.nowNum)
            reflashView()
           self.timeStop()
        }
    }
    //声音控制
    @IBAction func sliderValueChange(_ sender: UISlider) {
        AudioPlayer.voice(num: sender.value)
    }
   //界面被拉起时，刷新界面
    override func viewWillAppear(_ animated: Bool) {
            reflashView()
    }
//    func reflashView(num:Int){
//        self.musicArry=Music.getALL()
//        self.model=self.musicArry[num]
//        if model != nil {
//            self.albumImg.image=UIImage(data: self.model.musicimg!)
//            self.backGroundImg.image=UIImage(data: self.model.musicimg!)
//
//            self.MusicName.text=self.model.musicName
//            self.MusicAuthor.text=self.model.musicAuthor
//
//            self.model.isActive=true; //这首歌 是否是当前播放歌曲
//            
//            
//            self.rightTime.text=self.timeFormatted(totalSeconds: Int(AudioPlayer.musicDuration()))
//            print("hi i am cowBoy")
//        }
//        self.timer=Timer .scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.playProgress), userInfo: nil, repeats: true)
//        
//    }
    //刷新界面，用 新model 重新赋值
    func reflashView(){
        self.model=AudioPlayer.activeSong()
        if model != nil {
            self.musicArry=Music.getALL()
            self.nowNum=self.model.musicNum! - 1
            DispatchQueue.main.async(execute: {  //在主线程刷新界面
                self.albumImg.image=UIImage(data: self.model.musicimg!)
                self.backGroundImg.image=UIImage(data: self.model.musicimg!)
                self.MusicName.text=self.model.musicName
                
                if self.MusicName.text == "大鱼"{
                    self.mvButton.isHidden=false;
                }else{
                    self.mvButton.isHidden=true;
                }
                
                self.MusicAuthor.text=self.model.musicAuthor
                if AudioPlayer.isPlaying(){
                    self.playMusicBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
                }else{
                    self.playMusicBtn.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
                }
                //     self.model.isActive=true; //这首歌 是否是当前播放歌曲
                self.rightTime.text=self.timeFormatted(totalSeconds: Int(AudioPlayer.musicDuration()))
                //     print("hi i am cowBoy")
            })
            self.timer=Timer .scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.playProgress), userInfo: nil, repeats: true)
        }
        
        
    }
    // 关闭MV
    @IBAction func ShowMVButton(_ sender: UIButton) {
        var moreVC: MusicMVViewController!
        moreVC = self.storyboard?.instantiateViewController(withIdentifier: "MusicMVViewController") as! MusicMVViewController
    //    self.navigationController?.pushViewController(moreVC, animated: true)
        self.present(moreVC, animated: true, completion: nil)
        AudioPlayer.pause()
        
    }
    //歌曲进度条展示
    func playProgress(){
        self.musicProgress.progress=Float(AudioPlayer.progress())
        self.leftTime.text=timeFormatted(totalSeconds: Int(AudioPlayer.currentTime()))
        if AudioPlayer.isPlaying(){
            self.playMusicBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
        }else{
            self.playMusicBtn.setImage(#imageLiteral(resourceName: "playmusic"), for: .normal)
        }
        if AudioPlayer.activeSong() != self.model{
            reflashView()
        }
      //  print(Float(AudioPlayer.progress()))
//        if Float(AudioPlayer.progress()) > 0.99{
//            self.timeStop()
////            if AudioPlayer.musicRandomPlay(){
////                self.nowNum=Int(arc4random_uniform(UInt32(self.musicArry.count-1)))
////            }else{
//                self.nowNum=self.nowNum+1
////            }
//            if self.nowNum>=self.musicArry.count{
//                self.nowNum=self.musicArry.count - 1
//            }
//            if AudioPlayer.nextsong(num: self.nowNum){
//                self.playMusicBtn.setImage(#imageLiteral(resourceName: "stopMusic"), for: .normal)
//               // reflashView(num: self.nowNum)
//                
//                reflashView()
//                
//            }
//        }
    }
    
//    struct Random {
//        /**
//         * 如区间表示 ==> [1, end]
//         */
//        static func number(end: Int) -> [Int] {
//            var startArr = Array(1...end)
//            var resultArr = Array(count: end, repeatedValue: 0)
//            for i in 0..<startArr.count {
//                let currentCount = UInt32(startArr.count - i)
//                let index = Int(arc4random_uniform(currentCount))
//                resultArr[i] = startArr[index]
//                startArr[index] = startArr[Int(currentCount) - 1]
//            }
//            return resultArr
//        }
//        /**
//         *  如半闭区间表示 ==> (start, end]
//         */
//        static func numberPro(start: Int, end: Int) -> [Int] {
//            let scope = end - start
//            var startArr = Array(1...scope)
//            var resultArr = Array(count: scope, repeatedValue: 0)
//            for i in 0..<startArr.count {
//                let currentCount = UInt32(startArr.count - i)
//                let index = Int(arc4random_uniform(currentCount))
//                resultArr[i] = startArr[index]
//                startArr[index] = startArr[Int(currentCount) - 1]
//            }
//            return resultArr.map { $0 + start }
//        }
    //窗口被拉下时 停止计时器
    override func viewDidDisappear(_ animated: Bool) {
        self.timeStop()
    }
    //音乐时间格式转换
    func timeFormatted(totalSeconds:Int)->String{
        var seconds : String = String(totalSeconds % 60)
        var minutes :String = String((totalSeconds / 60) % 60);
        if seconds.characters.count == 1 {
            seconds="0"+seconds
        }
        if minutes.characters.count == 1{
            minutes="0"+minutes
        }
        //获取字符串长度
        return minutes+":"+seconds
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
