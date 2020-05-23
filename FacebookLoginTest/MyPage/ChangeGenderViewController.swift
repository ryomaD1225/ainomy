//
//  ChangeGenderViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/12.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit

class ChangeGenderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    var myTableView1: UITableView!
    var genderLabel:String!
    let userDefaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()

        myTable()
        navigationBar()
    }
    
    func myTable(){
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        // サイズを変更する
//        myTableView1 = UITableView(frame: CGRect(x: 0, y: self.view.frame.height/2, width: screenWidth, height: self.view.frame.height/2), style: UITableViewStyle.grouped)
        myTableView1 = UITableView(frame: self.view.frame, style: UITableViewStyle.grouped)
        myTableView1.delegate = self
        myTableView1.dataSource = self
        // trueで複数選択、falseで単一選択
        myTableView1.allowsMultipleSelection = false
        myTableView1.estimatedRowHeight = 100
        myTableView1.rowHeight = UITableViewAutomaticDimension
        
        self.view.addSubview(myTableView1)
    }
    
    //テーブル内のセクション数を決めるメソッド
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //テーブル内のセル数を決めるメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    //セルのインスタンスを生成するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "aaa")
        if indexPath.row == 0 {
            cell.textLabel?.text = "男性"

        }else if indexPath.row == 1 {
            cell.textLabel?.text = "女性"
        }

        return cell
    }
    
    //セルの高さを決めるメソッド
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    //セルを選択したときのイベントを処理する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .checkmark
        //ここで洗濯したセルの文字を取得
        if indexPath.row == 0 {
            print("第\(indexPath.section)セクションの\(indexPath.row)番セルが選択されました")
            genderLabel = "male"
            saveData(str: genderLabel)
            
        }else if indexPath.row == 1 {
            print("第\(indexPath.section)セクションの\(indexPath.row)番セルが選択されました")
            genderLabel = "female"
            saveData(str: genderLabel)
            
        }
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveData(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "saveGender")
        
    }
    
    // セルの選択が外れた時に呼び出される
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
            print("第\(indexPath.section)セクションの\(indexPath.row)番セルが選択されました")
        // チェックマークを外す
        cell?.accessoryType = .none
    }
    
    func navigationBar(){
        
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "私の性別は")
        
        //ナビゲーションバーの左ボタンを追加
        navItem.rightBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.myAction))
        
        //ナビゲーションバーにアイテムを追加
        navBar.pushItem(navItem, animated: true)
        // Viewにボタンを追加
        self.view.addSubview(navBar)
    }
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func myAction(){
        let storyboard: UIStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }
    
}
