//
//  BirthdayViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/06.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class BirthdayViewController: UIViewController {
    
    //=========UserDefaults のインスタンス========
    let userDefaults = UserDefaults.standard
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    var UserImage:UILabel!
    
    // インスタンス初期化
    let textField = UITextField()
    //ページコントロールのための変数を定義
    var pageControl = UIPageControl(frame: .zero)
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    var datePicker: UIDatePicker = UIDatePicker()
    var UserAge:Int!
    let button = UIButton()
    var userGender:String!
    
    
    private var birthDayChoice = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        readGender()
        setTest(str: "生年月日を選択してね")
        setupPageControl()
        inputText()
        pickerSetup()
        nextPage()
        
 
        // Do any additional setup after loading the view.
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readGender() -> String {
        
        let str: String = userDefaults.object(forKey: "saveGender") as! String
       
        userGender = str
        
        print("====userGender=====\(userGender)")
        return str
    }
    func setupPageControl() {
        
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        pageControl.numberOfPages = 4
        pageControl.currentPage = 3
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor.orange
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.8)
        //pageControlの位置とサイズを設定
        pageControl.frame = CGRect(x:0, y:height - 200, width:width, height:50)
        // 任意の場所に設置する
        pageControl.layer.position = CGPoint(x: self.view.frame.width/2, y:UserImage.frame.origin.y + 50)
      
        self.view.addSubview(pageControl)
    }
    
    func setTest(str: String) {
        UserImage = UILabel()
        UserImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        UserImage.text = str
        UserImage.sizeToFit()
        UserImage.center = self.view.center
        UserImage.frame.origin.y = UserImage.frame.origin.y - 250
        self.view.addSubview(UserImage)
        
    }
    
    func inputText(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // サイズ設定
        textField.frame.size.width = self.view.frame.width * 2 / 3
        textField.frame.size.height = 48
        
        // 位置設定
        textField.center.x = self.view.center.x
        textField.center.y = 240
        
        // プレースホルダー
        textField.placeholder = "生年月日を入力"
        
        // 背景色
        textField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        // 左の余白
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x:screenWidth/2, y:screenHeight/2, width: 10, height: 10))
        // 画像の中心を画面の中心に設定
        
        textField.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        
        // テキストを全消去するボタンを表示
        textField.clearButtonMode = .always
        
        // 改行ボタンの種類を変更
        textField.returnKeyType = .done
        
        // 画面に追加
        self.view.addSubview(textField)
    }
    
    func saveAge(str: String){
        
        userDefaults.set(str, forKey: "inputAge")
    }
    
    func pickerSetup(){
        // ピッカー設定
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        textField.inputView = datePicker
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    
    // 決定ボタン押下
    @objc func done() {
        textField.endEditing(true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        textField.text = "\(formatter.string(from: datePicker.date))"
        // 日付のフォーマット
        let now = NSDate()
        print("今日は\(now))です")
        
        let Age = now.timeIntervalSince(datePicker.date)//生まれてからの秒数
        
        let myAge2 = Int(Age)//秒齢
        let myAge3 = Double(myAge2)
        let myAge4 = Int(myAge2/60/60/24)//日齢
        let myAge5 = Int(myAge3/60/60/24/365.24)//年齢＿端数の切り捨て:満年齢:整数Integer
        UserAge = myAge5
        saveAge(str: myAge5.description)
        
        print("年齢は満\(myAge5)歳です")
        
        self.birthDayChoice = true
    }
    
    func nextPage(){
        
        // サイズを変更する
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        // 任意の場所に設置する
        button.layer.position = CGPoint(x: self.view.frame.width/2, y:570)
        
        // 文字色を変える
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        // 背景色を変える
        button.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1)
        
        // 枠の太さを変える
        button.layer.borderWidth = 1.0
        
        // 枠の色を変える
        button.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        button.layer.cornerRadius = 25
        
        // ボタンのタイトルを設定
        button.setTitle("はじめる", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        
        if UserAge < 20 {
            self.showAlert(message: "未成年者は本アプリをご利用できません")
        }
        print("=====ユーザの性別=====\(userGender!)")
        
        //ユーザが男性かつ、40歳以上ならアラートを出す
        if userGender! == "male" && UserAge >= 40 {
            self.showAlert(message: "40歳以上は本アプリをご利用できません")
        }
        
         //ユーザが女性かつ、35歳以上ならアラートを出す
        if userGender! == "female" && UserAge >= 35 {
            self.showAlert(message: "35歳以上は本アプリはご利用できません")
        }
        //空白だった場合の処理
        if let text = textField.text, !text.isEmpty {
            sendUserAge()
            
            let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
        }else{
            self.showAlert(message: "生年月日が選択されていません。")
        }
    }
    
    
    
    func sendUserAge(){
        ref.child("Users").child((user?.uid)!).updateChildValues(["age": UserAge])
    }


 
}
