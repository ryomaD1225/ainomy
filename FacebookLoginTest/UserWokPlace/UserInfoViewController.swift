//
//  UserInfoViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/05.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class UserInfoViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    let userDefaults = UserDefaults.standard
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    var UserImage:UILabel!
    //ページコントロールのための変数を定義
    var pageControl = UIPageControl(frame: .zero)
    // ボタンのインスタンス生成
    let button = UIButton()
    // カメラまたは写真から画像を選択したか？
    private var workPlace = false
    // インスタンス初期化
    var jobField = UITextField()
    // インスタンス初期化
    let nameField = UITextField()
    // インスタンス初期化
    let ageField = UITextField()

    //入力したかどうか確認
    private var workPlacechoiced = false
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    // dateピッカー
    var datePicker: UIDatePicker = UIDatePicker()
    var UserAge:Int!
    private var birthDayChoice = false
    var userGender:String!
    
    //=========UIScrollViewのインスタンス作成======
    var myScrollView: UIScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        viewScroll()
        setTest()
        setupPageControl()
        inputName()
        textName()
        inputAge()
        pickerSetup()
        textAge()
        inputWorkPlace()
        textWorkPlace()
        nextButton()
        navigationBar()
        backButton()
        
    }
    
    func viewScroll(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        // ScrollViewを生成.
        myScrollView = UIScrollView()
//        myScrollView.backgroundColor = UIColor.red;
        // ScrollViewの大きさを設定する.
        myScrollView.frame = self.view.frame
        
        // ScrollViewにcontentSizeを設定する.
        myScrollView.contentSize = CGSize(width:screenWidth, height:screenHeight)
        
        // ViewにScrollViewをAddする.
        self.view.addSubview(myScrollView)
    }

//======================= キーボードでtextfieldが隠れないようにする ===================
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MyPageViewController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MyPageViewController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        let txtLimit = jobField.frame.origin.y + jobField.frame.height + 8.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        
        print("テキストフィールドの下辺：(\(txtLimit))")
        print("キーボードの上辺：(\(kbdLimit))")
        
        if txtLimit >= kbdLimit {
            myScrollView.contentOffset.y = txtLimit - kbdLimit
        }
        
        if (10 >= (kbdLimit - txtLimit)) {
            myScrollView.contentOffset.y = 15
            print("差")
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        myScrollView.contentOffset.y = 0
    }
    
//======================= キーボードでtextfieldが隠れないようにする ===================
    func setTest() {
        
        UserImage = UILabel()
        UserImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        UserImage.text = """
        お名前・年齢・会社名を
        ご入力ください
        """
        UserImage.textAlignment = NSTextAlignment.center
        UserImage.numberOfLines = 2
        UserImage.sizeToFit()
        UserImage.center = self.view.center
        UserImage.frame.origin.y = UserImage.frame.origin.y - 200
        self.view.addSubview(UserImage)
        
    }
    
    func inputName(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        // サイズ設定
        nameField.frame.size.width = self.view.frame.width * 2 / 3
        nameField.frame.size.height = 48
        
        // プレースホルダー
        nameField.placeholder = "タップして入力name"
        
        // 背景色
        nameField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        // 左の余白
        nameField.leftViewMode = .always
        nameField.leftView = UIView(frame: CGRect(x:screenWidth/2, y:screenHeight/2, width: 10, height: 10))
        // 画像の中心を画面の中心に設定
        
        nameField.center = CGPoint(x:screenWidth/2, y:screenHeight/2 - 100)
        
        // テキストを全消去するボタンを表示
        nameField.clearButtonMode = .always
        
        // 改行ボタンの種類を変更
        nameField.returnKeyType = .done
        
        nameField.delegate = self
        
        // 画面に追加
        self.view.addSubview(nameField)
    }
    
    func textName(){
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: nameField.frame.origin.x, y: nameField.frame.origin.y - 20, width: 10, height: 10)
        nameLabel.text = "お名前 (必須)"
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.textColor = UIColor.darkGray
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.sizeToFit()
        self.view.addSubview(nameLabel)
        
    }
    
    func inputAge(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // サイズ設定
        ageField.frame.size.width = self.view.frame.width * 2 / 3
        ageField.frame.size.height = 48
        
        // プレースホルダー
        ageField.placeholder = "タップして入力age"
        
        // 背景色
        ageField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        // 左の余白
        ageField.leftViewMode = .always
        ageField.leftView = UIView(frame: CGRect(x:screenWidth/2, y:screenHeight/2, width: 10, height: 10))
        // 画像の中心を画面の中心に設定
        
        ageField.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        
        // テキストを全消去するボタンを表示
        ageField.clearButtonMode = .always
        
        // 改行ボタンの種類を変更
        ageField.returnKeyType = .done
        
        ageField.delegate = self
        
        // 画面に追加
        self.view.addSubview(ageField)
    }
    
    func textAge(){
        
        let ageLabel = UILabel()
        ageLabel.frame = CGRect(x: ageField.frame.origin.x, y: ageField.frame.origin.y - 20, width: 10, height: 10)
        ageLabel.text = "年齢 (必須)"
        ageLabel.font = UIFont.systemFont(ofSize: 15)
        ageLabel.textColor = UIColor.darkGray
        ageLabel.textAlignment = NSTextAlignment.center
        ageLabel.sizeToFit()
        self.view.addSubview(ageLabel)
    }
    
    func pickerSetup(){
        
        // ピッカー設定
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        ageField.inputView = datePicker
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        ageField.inputView = datePicker
        ageField.inputAccessoryView = toolbar
    }
    
    // 決定ボタン押下
    @objc func done() {
        ageField.endEditing(true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        ageField.text = "\(formatter.string(from: datePicker.date))"
        // 日付のフォーマット
        let now = NSDate()
        print("今日は\(now))です")
        
        let Age = now.timeIntervalSince(datePicker.date)//生まれてからの秒数
        
        let myAge2 = Int(Age)//秒齢
        let myAge3 = Double(myAge2)
        // let myAge4 = Int(myAge2/60/60/24)//日齢
        let myAge5 = Int(myAge3/60/60/24/365.24)//年齢＿端数の切り捨て:満年齢:整数Integer
        
         print("年齢は満\(myAge5)歳です")
        
       
        
        UserAge = myAge5
        saveAge(str: myAge5.description)
        
       
        
        self.birthDayChoice = true
    }
    
    func saveAge(str: String){
        
        userDefaults.set(str, forKey: "inputAge")
    }
    
    
    
    func inputWorkPlace(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // サイズ設定
        jobField.frame.size.width = self.view.frame.width * 2 / 3
        jobField.frame.size.height = 48
        
        // 位置設定
        jobField.center.x = self.view.center.x
        jobField.center.y = 240
        
        // プレースホルダー
        jobField.placeholder = "タップして入力job"
        
        // 背景色
        jobField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        // 左の余白
        jobField.leftViewMode = .always
        jobField.leftView = UIView(frame: CGRect(x:screenWidth/2, y:screenHeight/2, width: 10, height: 10))
        // 画像の中心を画面の中心に設定
        
        jobField.center = CGPoint(x:screenWidth/2, y:screenHeight/2  + 100)
        
        // テキストを全消去するボタンを表示
        jobField.clearButtonMode = .always
        
        // 改行ボタンの種類を変更
        jobField.returnKeyType = .done
        
        jobField.delegate = self
        
        // 画面に追加
        self.myScrollView.addSubview(jobField)
    }
    
    func textWorkPlace(){
        let workPlaceLabel = UILabel()
        workPlaceLabel.frame = CGRect(x: jobField.frame.origin.x, y: jobField.frame.origin.y - 20, width: 10, height: 10)
        workPlaceLabel.text = "会社名 (必須)"
        workPlaceLabel.font = UIFont.systemFont(ofSize: 15)
        workPlaceLabel.textColor = UIColor.darkGray
        workPlaceLabel.textAlignment = NSTextAlignment.center
        workPlaceLabel.sizeToFit()
        self.myScrollView.addSubview(workPlaceLabel)
    }
    
    func nextButton(){
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
        button.setTitle("次へ", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
        
    }
    
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを隠す
        textField.resignFirstResponder()
        // 設定済みをマーク.
        self.workPlacechoiced = true
        
        print("改行ボタンを押した時の処理")
        
        return true
    }
    
    // クリアボタンが押された時の処理
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("Clear")
        return true
    }
    
    // テキストフィールドがフォーカスされた時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Start")
        jobField = textField
        return true
    }
    
    // テキストフィールドでの編集が終わろうとするときの処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("End")
        return true
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        
        //空白だった場合の処理
        if jobField.text!.isEmpty || ageField.text!.isEmpty || nameField.text!.isEmpty{
             self.showAlert(message: "全ての項目を入力しましょう")
        }else{
            saveJob(str: jobField.text!)
            saveName(str: nameField.text!)
            sendWorkPlace()
            let storyboard: UIStoryboard = UIStoryboard(name: "UserImage", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
           
        }

        
    }
    
    func navigationBar(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        let TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 64))
        let bgColor = UIColor.white
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
    }
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func screenTranstion(tapGestureRecognizer: UITapGestureRecognizer){
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }
    
    func backButton(){
        let items = UIBarButtonItem(barButtonHiddenItem: .Back, target: nil, action: #selector(self.myAction))
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "プロフィール登録")

        //ナビゲーションバーの左ボタンを追加
        navItem.leftBarButtonItem = items

        //ナビゲーションバーにアイテムを追加
        navBar.pushItem(navItem, animated: true)
        // Viewにボタンを追加
        self.view.addSubview(navBar)
    }
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func myAction(){
        print("できたよ")
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupPageControl() {
        
        
        let label2 = UILabel(frame: CGRect(x: self.view.frame.width/2, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label2.text = " STEP2";
        label2.sizeToFit();
        label2.layer.position = CGPoint(x: self.view.frame.width/2, y:UserImage.frame.origin.y - 50)
        
        label2.textColor = UIColor.black
        self.view.addSubview(label2);
        
        let label1 = UILabel(frame: CGRect(x:label2.frame.origin.x - 75, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label1.text = "STEP1  >";
        label1.sizeToFit();
        label1.textColor = UIColor.black
        self.view.addSubview(label1);
        
        
        let label3 = UILabel(frame: CGRect(x:label2.frame.origin.x + 65, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label3.text = ">  STEP3";
        label3.sizeToFit();
        label3.textColor = UIColor.lightGray
        self.view.addSubview(label3);
        
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveJob(str: String){
        
        userDefaults.set(str, forKey: "inputJob")
    }
    
    func saveName(str: String){
        
        userDefaults.set(str, forKey: "saveName")
    }
  
    func sendWorkPlace(){
        ref.child("Users").child((user?.uid)!).updateChildValues(["companyName": jobField.text])
        ref.child("Users").child((user?.uid)!).updateChildValues(["name": nameField.text])
        ref.child("Users").child((user?.uid)!).updateChildValues(["age": UserAge])
    }
    

}



//========= 年齢確認 =========
//        if UserAge < 20 {
//            self.showAlert(message: "未成年者は本アプリをご利用できません")
//
//        }
//        print("=====1=====\(userGender!)")
//
//        //ユーザが男性かつ、40歳以上ならアラートを出す
//        if userGender! == "male" && UserAge >= 40 {
//            self.showAlert(message: "40歳以上は本アプリをご利用できません")
//
//        }
//        print("=====2=====\(userGender!)")
//        //ユーザが女性かつ、35歳以上ならアラートを出す
//        if userGender! == "female" && UserAge >= 35 {
//            self.showAlert(message: "35歳以上は本アプリはご利用できません")
//
//        }
//        print("=====3=====\(userGender!)")
//========= 年齢確認 =========
