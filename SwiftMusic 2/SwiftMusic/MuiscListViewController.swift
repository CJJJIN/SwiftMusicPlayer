//
//  MuiscListViewController.swift
//  SwiftMusic
//
//  Created by 科文 on 2017/5/3.
//  Copyright © 2017年 科文. All rights reserved.
//

import UIKit
import AVFoundation

final class MuiscListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableVIew: UITableView!
 //   var modalVC :DetailMusicViewController!
    var musicArry:Array<Music>!
    var musicPlayByTableViewCell: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.modalVC=self.storyboard?.instantiateViewController(withIdentifier: "DetailMusicViewController") as! DetailMusicViewController
//        self.modalVC.modalPresentationStyle = .overFullScreen//弹出属性
        tableVIew.dataSource=self
        tableVIew.delegate=self
        self.musicArry=Music.getALL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicArry.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicListTableViewCell
        cell.setModel(model: self.musicArry[indexPath.row])
//        cell.musicAuthor.text=self.musicArry[indexPath.row].musicAuthor
//        cell.musicName.text=self.musicArry[indexPath.row].musicName
//         cell.isSelected=false
//        cell.selectionStyle=UITableViewCellSelectionStyle.none
//        if cell.isSelected{
//            cell.activeImg.isHidden=false;
//            cell.setSelected(false, animated: false)
//            cell.selectedBackgroundView?.tintColor=UIColor.green
//        }else{
//            cell.activeImg.isHidden=true;
//        }
//      cell.musicNumber.text=String(indexPath.row+1)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        musicPlayByTableViewCell?(indexPath.row)
 //       let cell = tableView.cellForRow(at: indexPath) as! MusicListTableViewCell
//        cell.selectionStyle=UITableViewCellSelectionStyle.default
//        cell.setSelected(false, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)//取消被选中状态
            //    musicPlayByTableViewCell?(["wen":"123"])
//      self.present(self.modalVC, animated:true , completion: nil)
        
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


