//
//  Music.swift
//  SwiftMusic
//
//  Created by 科文 on 2017/5/2.
//  Copyright © 2017年 科文. All rights reserved.
//

import UIKit
import AVFoundation
class Music: NSObject {

    var musicName :String?
    var musicURL :URL?
    var musicimg :Data?
    var musicAuthor :String?
    var musicAlbum :String?
    var musicNum:Int?
    var isActive:Bool=false
    private static var musicArry:Array<Music>? = nil
//    init(title:String,artist:String,album:String,file:String) {
//        self.musicName = title
//        self.musicAuthor = artist
//        self.musicAlbum = album
//        self.musicURL = file
//    }
    static func getALL()->Array<Music>{
        if musicArry == nil {
            var musicArryList=Array<Music>()
            var fileArry:[String]?
            var num:Int=0;
            let path=Bundle.main.path(forResource:"mymusic", ofType: nil)
            do{
                try fileArry=FileManager.default.contentsOfDirectory(atPath: path!)
            }
            catch{
                print("error")
            }
            for n in fileArry! {
                let singlePath=path!+"/"+n
                let avURLAsset = AVURLAsset(url: URL.init(fileURLWithPath: singlePath))
                let musicModel:Music = Music()
                
                for i in avURLAsset.availableMetadataFormats {
                    
                    for j in avURLAsset.metadata(forFormat: i) {
                        //歌曲名
                        if j.commonKey == "title"{
                            musicModel.musicName = j.value as? String
                            
                        }//封面图片
                        if j.commonKey == "artwork"{
                            musicModel.musicimg=j.value as? Data// 这里是个坑坑T T
                        }//专辑名
                        if j.commonKey == "albumName"{
                            musicModel.musicAlbum=j.value as? String
                        }
                        //歌手
                        if j.commonKey == "artist"{
                            musicModel.musicAuthor=j.value as? String
                        }
                    }
                    
                }
                musicModel.musicURL=URL.init(fileURLWithPath: singlePath)
                num += 1
                musicModel.musicNum=num;
                musicArryList.append(musicModel)
            }
            musicArry=musicArryList
            return musicArry!

        }else{
            return musicArry!
        }
    }
}
