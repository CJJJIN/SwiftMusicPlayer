//
//  AudioPlayer.swift
//  SwiftMusic
//
//  Created by 科文 on 2017/5/4.
//  Copyright © 2017年 科文. All rights reserved.
//

import UIKit
import AVFoundation
final class AudioPlayer: NSObject {
    private static var instance: AVAudioPlayer? = nil //static 直到被销毁 全局存在
    private static var activeMusic:Music?=nil
    private static var isRandomPlay=false
    static func share(model:Music) -> Bool {
            do{
                try instance = AVAudioPlayer(contentsOf: model.musicURL!)
            }
            catch{
                instance=nil;
                print("error")
                return false;
            }
            instance?.play()
            activeMusic=model
            return true
    }
    //停止
    static func stop(){
        instance?.stop()
    }
    //播放
    static func play()->Bool{
        if (instance?.isPlaying)! {
            instance?.pause()
            return false
        }else{
            instance?.play()
            return true
        }
    }
    //暂停
    static func pause(){
        instance?.pause()
    }
    //下一曲
    static func nextsong( num:Int)->Bool{
        var num = num
        var musicArry:Array<Music>!
        musicArry=Music.getALL()
        if isRandomPlay{
           num = Int(arc4random_uniform(UInt32(musicArry.count-1)))
        }
        if(share(model: musicArry[num])){
            return true
        }else{
            return false
        }
    }
    //上一曲
    static func prevsong(num:Int)->Bool{
        var num = num
        var musicArry:Array<Music>!
        musicArry=Music.getALL()
        if isRandomPlay{
            num = Int(arc4random_uniform(UInt32(musicArry.count-1)))
        }
        if(share(model: musicArry[num])){
            return true
        }else{
            return false
        }
    }
    //声音控制
    static func voice(num:Float){
        instance?.volume=num
    }
    //进度条相关
    static func progress()->Double{
        return (instance?.currentTime)!/(instance?.duration)!
    }
    static func musicDuration()->Double{
        return (instance?.duration)!
    }
    
    static func currentTime()->Double{
        return (instance?.currentTime)!
    }
 
    //当前播放的音乐
    static func activeSong()->Music?{
        return activeMusic
    }
    //是否在播放音乐
    static func isPlaying()->Bool{
        return (instance?.isPlaying)!
    }
    //随机播放
    static func musicRandomPlay()->Bool{
        if  isRandomPlay==false{
            isRandomPlay=true
            return isRandomPlay
        }else{
            isRandomPlay=false
            return isRandomPlay
        }
    }
    
}
