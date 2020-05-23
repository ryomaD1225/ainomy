//
//  MyPageViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/06.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

import FBSDKCoreKit
import FacebookCore
import FBSDKLoginKit
import FacebookLogin

// 画像トリミングライブラリ
import CropViewController

class MyPageViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate, UITextViewDelegate{
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("======test=====")
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
       print("=====logout=====")
    }
    
    
    //=========UserDefaults のインスタンス========
    let userDefaults = UserDefaults.standard
    // ドキュメントディレクトリの「ファイルURL」（URL型）
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    // ドキュメントディレクトリの「パス」（String型）
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    //let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var ref: DatabaseReference!
    
    let user = Auth.auth().currentUser
    
    //=========UIScrollViewのインスタンス作成======
    var myScrollView: UIScrollView!
    //================UserDefaults保存組===================

    var selfIntroduction = UITextView()
    var testText:String = ""
    
    let selfJob = UITextField()
    var selfJobText:String = ""
    
    let selfEducation = UITextField()
    var selfEducationText:String = ""
    //================UserDefaults保存組===================
    let matchUsersGender = UITextField()
    var txtActiveField = UITextField()
    var txtActiveView = UITextView()
    var activeTextView: UITextView?
    
    var imageView: UIImageView!
    
    //=======ナビゲーションバーのインスタンス==========
    let navBar = UINavigationBar()
    //=======ナビゲーションバーのインスタンス==========
    
    var myTalbeView:  UITableView!
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    var disappeareLabel: UILabel!
    var selectedGenderLabel:String!
    let sectionName = ["自己紹介","勤め先","学歴","性別"]
    
    // removeObserver用に定義
    var handler: UInt = 0
    
    // ユーザの性別を代入するために定義
    var genderInfo:String!
    
    // ユーザが選択した人数を代入するための変数を定義
    var NumberOfPeople:String!
    // 名前と年齢表示するためのラベル定義
    var nameAndAgel:UILabel!
    var education:UILabel!
    var Introducing:UILabel!
    var lengthLabel:UILabel!
    var companyLabe:UILabel!
    var educationBackground:UILabel!
    var gender:UILabel!
    var sexSelect:UILabel!
    var detailButton: UIButton!
    var backHomeLabel: UILabel!
    var disappearSwich:UISwitch!
    var facebookLabel:UILabel!
    var userUID:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        userUID = user?.uid
        
        viewScroll()
        navigationBar()
        initImageView()
        nameLabel()
        educationLabel()
        selfLabel()
        inputSelf()
        charactorsNumbers()
        jobLabel()
        inputJob()
        educationLabel2()
        educationJob()
        genderLabel()
        selectedGender()
        detailInfo()
        backHome()
        disappearLabel()
        disappear()
        facebookLogout()
   
    }
    
    
    
    
    
//==========================================userDefaults画面==========================================
    func readData() -> String {

        let str: String = userDefaults.object(forKey: "inputSelf") as! String
        
        return str
    }

    func saveData(str: String){
        userDefaults.set(str, forKey: "inputSelf")
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readJob() -> String {
        
        let str: String = userDefaults.object(forKey: "inputJob") as! String
        
        return str
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveJob(str: String){
        
        userDefaults.set(str, forKey: "inputJob")
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readEducation() -> String {
        
        let str: String = userDefaults.object(forKey: "inputEducation") as! String
        
        return str
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveEducation(str: String){
        
        userDefaults.set(str, forKey: "inputEducation")
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readGender() -> String {
        
        let str: String = userDefaults.object(forKey: "saveGender") as! String
        genderInfo = str
        return str
    }
    
    func readAge() -> String {
        
        let str: String = userDefaults.object(forKey: "inputAge") as! String
        
        return str
    }
    
    func readName() -> String {
        
        let str: String = userDefaults.object(forKey: "saveName") as! String
        
        return str
    }
    
//==========================================userDefaults画面==========================================
    
    
    func viewScroll(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        // ScrollViewを生成.
        myScrollView = UIScrollView()
        // ScrollViewの大きさを設定する.
        myScrollView.frame = self.view.frame

        // ScrollViewにcontentSizeを設定する.
        myScrollView.contentSize = CGSize(width:screenWidth, height:screenHeight * 2.0)
        
        // ViewにScrollViewをAddする.
        self.view.addSubview(myScrollView)
    }
    
    func nameLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
//        let screenHeight:CGFloat = view.frame.size.height
        nameAndAgel = UILabel()
        nameAndAgel.frame = CGRect(x:150, y:200, width:300, height:30)
        nameAndAgel.text = "\(readName()), \(readAge())"
        nameAndAgel.font = UIFont.systemFont(ofSize: 25.0)
        nameAndAgel.textAlignment = .center
        // 画像の中心を画面の中心に設定
        nameAndAgel.center = CGPoint(x:screenWidth/2 - 30, y:imageView.frame.origin.y + 220)
        nameAndAgel.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(nameAndAgel)
        
        nameAndAgel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 17.0).isActive = true
        nameAndAgel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    

    func educationLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
//        let screenHeight:CGFloat = view.frame.size.height
        education = UILabel()
        education.frame = CGRect(x:150, y:200, width:screenWidth, height:30)
        education.text = readJob()
        education.font = UIFont.systemFont(ofSize: 17.0)
        education.textAlignment = .center
        // 画像の中心を画面の中心に設定
//        education.center = CGPoint(x:screenWidth/2, y:label.frame.origin.y + 130)
        education.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(education)
        
        education.topAnchor.constraint(equalTo: nameAndAgel.bottomAnchor, constant: 10.0).isActive = true
        education.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func selfLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        Introducing = UILabel()
        Introducing.frame = CGRect(x:150, y:200, width:80, height:30)
        Introducing.text = "自己紹介"
        Introducing.textAlignment = .left
        // 画像の中心を画面の中心に設定
        Introducing.center = CGPoint(x:screenWidth * 0.15, y:screenHeight/2)
        Introducing.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(Introducing)
        
        Introducing.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        Introducing.topAnchor.constraint(equalTo: education.bottomAnchor, constant: 60.0).isActive = true
        
        
    }
    
    func inputSelf(){
        
        selfIntroduction.delegate = self
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // サイズ設定
        selfIntroduction.frame.size.width = self.view.frame.width
        selfIntroduction.frame.size.height = 150
        
        selfIntroduction.font = UIFont.systemFont(ofSize: 23.0)
        
        // 位置設定
        selfIntroduction.center.x = self.view.center.x
        selfIntroduction.center.y = 240
        
        // 背景色
        selfIntroduction.backgroundColor = .white
        
        // 画像の中心を画面の中心に設定
        selfIntroduction.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 50)
 
        // デフォルト値
        userDefaults.register(defaults: ["inputSelf": "default"])
        
        selfIntroduction.text = readData()
        
        selfIntroduction.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 画面に追加
        self.myScrollView.addSubview(selfIntroduction)
        selfIntroduction.topAnchor.constraint(equalTo: Introducing.bottomAnchor, constant: 20.0).isActive = true
        selfIntroduction.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        selfIntroduction.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.20).isActive = true
        selfIntroduction.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true

        //////////UIToolBarの設定////////////////////
        // https://fussan-blog.com/uikit-uitextview/
        //キードードを閉じるボタンを作るためにツールバーを生成
        let toolBar = UIToolbar()
        
        //toolBarのサイズを設定
        toolBar.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        
        //画面幅に合わせるように設定
        toolBar.sizeToFit()
        
        //Doneボタンを右に配置するためのスペース
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        //Doneボタン
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MyPageViewController.doneButton))
        
        //ツールバーにボタンを設定
        toolBar.items = [space,doneButton]
        
        //textViewにツールバーを設定
        selfIntroduction.inputAccessoryView = toolBar
        
        //Viewに追加
        self.myScrollView.addSubview(selfIntroduction)
    }

    func charactorsNumbers(){
        // 文字数を表示
        // https://qiita.com/hi_erica_/items/c8f9ad040e4695f41edb
        lengthLabel = UILabel()
        lengthLabel.frame = CGRect(x:150, y:200, width:view.frame.size.width, height:30)
        lengthLabel.text = String(selfIntroduction.text.count)
        lengthLabel.font = UIFont.systemFont(ofSize: 20.0)
        lengthLabel.textColor = UIColor.lightGray
        lengthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(lengthLabel)
        
        lengthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        lengthLabel.bottomAnchor.constraint(equalTo: selfIntroduction.bottomAnchor, constant: -20.0).isActive = true
    }
    
    // UITextviewで文字が入力されるたびに呼び出される
    func textViewDidChange(_ textView: UITextView){
        lengthLabel.text = String(selfIntroduction.text.count)
    }
 
    
    //doneボタンを押した時の処理
    @objc func doneButton(){
        //================自己紹介storage=============
        testText = selfIntroduction.text!
        selfIntroduction.text = testText
        saveData(str: testText)
        print("testText==============\(testText)")
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    // 以下でUITextviewの文字制限をしている
    //https://www.hackingwithswift.com/example-code/uikit/how-to-limit-the-number-of-characters-in-a-uitextfield-or-uitextview
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = selfIntroduction.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= 100
    }


    
    func jobLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        companyLabe = UILabel()
        companyLabe.frame = CGRect(x:150, y:200, width:120, height:30)
        companyLabe.text = "勤め先/職業"
        companyLabe.textAlignment = .center
        // 画像の中心を画面の中心に設定
        companyLabe.center = CGPoint(x:screenWidth * 0.15, y:screenHeight/2 + 125)
        companyLabe.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(companyLabe)
        companyLabe.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        companyLabe.topAnchor.constraint(equalTo: selfIntroduction.bottomAnchor, constant: 30.0).isActive = true
        
        
    }
    
    func inputJob(){
        
        selfJob.delegate = self
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // サイズ設定
        selfJob.frame.size.width = self.view.frame.width
        selfJob.frame.size.height = 48
        
        // 位置設定
        selfJob.center.x = self.view.center.x
        selfJob.center.y = 240
    
        // 背景色
        selfJob.backgroundColor = .white
        
        // 画像の中心を画面の中心に設定
        selfJob.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 170)
        
        // テキストを全消去するボタンを表示
        selfJob.clearButtonMode = .always
        
        // 改行ボタンの種類を変更
        selfJob.returnKeyType = .done
        
        // デフォルト値
        userDefaults.register(defaults: ["inputJob": "default"])
        
        selfJob.text = readJob()
        selfJob.font = UIFont.systemFont(ofSize: 20.0)
        // https://teratail.com/questions/40654 頭に隙間を入れる
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        paddingView.backgroundColor = UIColor.clear
        selfJob.leftView = paddingView
        selfJob.leftViewMode = .always
        
        selfJob.translatesAutoresizingMaskIntoConstraints = false
        // 画面に追加
        self.myScrollView.addSubview(selfJob)
        
        selfJob.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        selfJob.topAnchor.constraint(equalTo: companyLabe.bottomAnchor, constant: 10.0).isActive = true
        selfJob.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
    }
    
    
    func educationLabel2(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        educationBackground = UILabel()
        educationBackground.frame = CGRect(x:150, y:200, width:80, height:30)
        educationBackground.text = "学歴"
        educationBackground.textAlignment = .left
        // 画像の中心を画面の中心に設定
        educationBackground.center = CGPoint(x:screenWidth * 0.15, y:screenHeight/2 + 235)
        educationBackground.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(educationBackground)
        
        educationBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        educationBackground.topAnchor.constraint(equalTo: selfJob.bottomAnchor, constant: 30.0).isActive = true
        
    }
    
    func educationJob(){
        
        selfEducation.delegate = self
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // サイズ設定
        selfEducation.frame.size.width = self.view.frame.width
        selfEducation.frame.size.height = 48
        
        // 位置設定
        selfEducation.center.x = self.view.center.x
        selfEducation.center.y = 240
        
        // 背景色
        selfEducation.backgroundColor = .white
        
        // 画像の中心を画面の中心に設定
        selfEducation.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 280)
        
        // テキストを全消去するボタンを表示
        selfEducation.clearButtonMode = .always
        
        // 改行ボタンの種類を変更
        selfEducation.returnKeyType = .done
        
        // デフォルト値
        userDefaults.register(defaults: ["inputEducation": "default"])
        
        selfEducation.text = readEducation()
        selfEducation.font = UIFont.systemFont(ofSize: 20.0)
        
        // https://teratail.com/questions/40654 頭に隙間を入れる
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        paddingView.backgroundColor = UIColor.clear
        selfEducation.leftView = paddingView
        selfEducation.leftViewMode = .always
        
        selfEducation.translatesAutoresizingMaskIntoConstraints = false
        // 画面に追加
        self.myScrollView.addSubview(selfEducation)
        
        selfEducation.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        selfEducation.topAnchor.constraint(equalTo: educationBackground.bottomAnchor, constant: 10.0).isActive = true
        selfEducation.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
        
    }
    

    //改行ボタンが押された際に呼ばれる.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //================自己紹介storage=============
        testText = selfIntroduction.text!
        selfIntroduction.text = testText
        saveData(str: testText)
        print("testText==============\(testText)")
        //================勤め先storage=============
        selfJobText = selfJob.text!
        selfJob.text = selfJobText
        saveJob(str: selfJobText)
        //================学歴storage=============
        selfEducationText = selfEducation.text!
        selfEducation.text = selfEducationText
        saveEducation(str: selfEducationText)
        //================学歴storage=============
        
        textField.resignFirstResponder()
        
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
        txtActiveField = textField
        activeTextView = nil
        print("textField_Start")
        return true
    }
    
    // UITextViewが選択された場合
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("UITextView_Start")
        txtActiveView = textView
        activeTextView = textView
        return true
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // キーボードの出力時にtextfieldが隠れないようにする処理
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MyPageViewController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MyPageViewController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    

    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
     
        if activeTextView == nil {
        // UITextField
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        let txtLimit = txtActiveField.frame.origin.y + txtActiveField.frame.height + 8.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
       
        print("テキストフィールドの下辺：(\(txtLimit))")
        print("キーボードの上辺：(\(kbdLimit))")
        
        if txtLimit >= kbdLimit {
            print("走っている")
            myScrollView.contentOffset.y = txtLimit - kbdLimit
        }
        }else{
            let userInfo = notification.userInfo!
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let myBoundSize: CGSize = UIScreen.main.bounds.size
            let txtLimit = txtActiveView.frame.origin.y + txtActiveView.frame.height + 8.0
            let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
            
            print("テキストフィールドの下辺：(\(txtLimit))")
            print("キーボードの上辺：(\(kbdLimit))")
            
            if txtLimit >= kbdLimit {
                print("走っている")
                myScrollView.contentOffset.y = txtLimit - kbdLimit
            }
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        myScrollView.contentOffset.y = 0
    }
    
    // テキストフィールドでの編集が終わろうとするときの処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("End")
        return true
    }
///============================================================
    func genderLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        gender = UILabel()
        gender.frame = CGRect(x:150, y:200, width:80, height:30)
        gender.text = "性別"
        gender.textAlignment = .left
        // 画像の中心を画面の中心に設定
        gender.center = CGPoint(x:screenWidth * 0.15, y:screenHeight/2 + 345)
        gender.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(gender)
        
        gender.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        gender.topAnchor.constraint(equalTo: selfEducation.bottomAnchor, constant: 30.0).isActive = true
        
    }
    
    func selectedGender(){
        print("===================selectedGenderLabel===================")
        if selectedGenderLabel != nil {
            print(selectedGenderLabel)
        }
       
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        //インスタンス生成
        sexSelect = UILabel()
        // サイズ設定
        sexSelect.frame.size.width = self.view.frame.width
        sexSelect.frame.size.height = 48
        // 背景色
        sexSelect.backgroundColor = .white
        let userGender = readGender()
        if userGender == "male"{
            sexSelect.text = "  男性"
        }else{
            sexSelect.text = "  女性"
        }
        sexSelect.font = UIFont.systemFont(ofSize: 20.0)
        sexSelect.textAlignment = .left
        sexSelect.textColor = UIColor(white:0.35, alpha:1.0)
        // 画像の中心を画面の中心に設定
        sexSelect.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 390)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDidBeginEditing(tapGestureRecognizer:)))
        sexSelect.isUserInteractionEnabled = true
        sexSelect.addGestureRecognizer(tapGestureRecognizer)
        
        sexSelect.translatesAutoresizingMaskIntoConstraints = false
        // 画面に追加
        self.myScrollView.addSubview(sexSelect)
        
        sexSelect.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        sexSelect.topAnchor.constraint(equalTo: gender.bottomAnchor, constant: 10.0).isActive = true
        sexSelect.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
    
    }
    
    @objc private func textDidBeginEditing(tapGestureRecognizer: UITapGestureRecognizer){
        print("you tatched")// handle begin editing event
        // 性別へ遷移するためにSegueを呼び出す。同じストーリーボードのビューに遷移する場合
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "changeGender")
        present(nextView, animated: true, completion: nil)
    }
    
    func detailInfo(){
        // http://swift.attojs.com/index.php/2016/02/23/how-to-create-different-types-of-buttons/
        detailButton = UIButton(type: UIButtonType.detailDisclosure)
        detailButton.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        detailButton.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControlEvents.touchUpInside)
        detailButton.sizeToFit()
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(detailButton)
        
        detailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        detailButton.topAnchor.constraint(equalTo: sexSelect.topAnchor, constant: 17.0).isActive = true
    }
    
    @objc func buttonEvent(_ sender: UIButton) {
        showAlert(message: " 異性のみとマッチします。同性とはマッチしません。")
    }
    
    func backHome(){
        
       // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        //インスタンス生成
        backHomeLabel = UILabel()
        // サイズ設定
        backHomeLabel.frame.size.width = self.view.frame.width
        backHomeLabel.frame.size.height = 48
        // 背景色
        backHomeLabel.backgroundColor = .white
        backHomeLabel.text = "帰宅する"
        backHomeLabel.textAlignment = .center
        // 画像の中心を画面の中心に設定
        backHomeLabel.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 500)

        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backHomeButton(tapGestureRecognizer:)))
        backHomeLabel.isUserInteractionEnabled = true
        backHomeLabel.addGestureRecognizer(tapGestureRecognizer)
        backHomeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(backHomeLabel)
        
        backHomeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        backHomeLabel.topAnchor.constraint(equalTo: sexSelect.bottomAnchor, constant: 55.0).isActive = true
        backHomeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
        
    }

    
    @objc private func backHomeButton(tapGestureRecognizer: UITapGestureRecognizer){
        print("go Home")
        let modal = UIViewController()
        modal.modalPresentationStyle = .custom
        modal.transitioningDelegate = self
        present(modal, animated: true, completion: nil)
    }
    
    func disappear(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        //UISwicthのインスタンスを生成
        disappearSwich = UISwitch()
        // 画像の中心を画面の中心に設定
        disappearSwich.center = CGPoint(x:screenWidth - 50, y:screenHeight/2 + 610)
        //swiをoffに設定
        disappearSwich.isOn = true
        //swiが押された時の処理を設定
        disappearSwich.addTarget(self, action: #selector(MyPageViewController.switchClick(sender:)), for: UIControlEvents.valueChanged)
        disappearSwich.translatesAutoresizingMaskIntoConstraints = false
        //viewにsubviewとして追加
        self.myScrollView.addSubview(disappearSwich)
        disappearSwich.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        disappearSwich.topAnchor.constraint(equalTo: disappeareLabel.topAnchor, constant: 17.0).isActive = true
    }
    
    //swiが押された時の処理の中身
    @objc func switchClick(sender: UISwitch){
        
        if sender.isOn {
            print("On")
            disappeareLabel.text = "   ainomyで表示する"
            ref.child("selected").child((self.user?.uid)!).child("number").observeSingleEvent(of: .value, with: { (snapshot) in
                self.ref.child("selected").child((self.user?.uid)!).child("number").removeObserver(withHandle: self.handler)
                if snapshot.exists(){
                    self.NumberOfPeople = snapshot.value as? String
                    let data = ["false":self.user?.uid]
                    self.ref.child("field").child(self.genderInfo).child(self.NumberOfPeople).child((self.user?.uid)!).setValue(data)
                }else{
                    print("まだ人数を選んでないよ。")
                }
            })
        }else {
            print("Off")
            disappeareLabel.text = "   ainomyで表示しない"
            ref.child("selected").child((self.user?.uid)!).child("number").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists(){
                   self.NumberOfPeople = snapshot.value as? String
                    let data = ["false":self.user?.uid]
                    self.ref.child("field").child(self.genderInfo).child(self.NumberOfPeople).child((self.user?.uid)!).setValue(data)
                }else{
                     print("まだ人数を選んでないよ。")
                }
            })
        }
    }
    
    func disappearLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        //インスタンス生成
        disappeareLabel = UILabel()
        // サイズ設定
        disappeareLabel.frame.size.width = screenWidth
        disappeareLabel.frame.size.height = 48
        // 背景色
        disappeareLabel.backgroundColor = .white
        disappeareLabel.text = "   ainomyで表示する"
        disappeareLabel.textColor = UIColor(white:0.35, alpha:1.0)
        disappeareLabel.textAlignment = .left
        // 画像の中心を画面の中心に設定
        disappeareLabel.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 610)
        disappeareLabel.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(disappeareLabel)
        disappeareLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        disappeareLabel.topAnchor.constraint(equalTo: backHomeLabel.bottomAnchor, constant: 55.0).isActive = true
        disappeareLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
    }
    
    
    func facebookLogout(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        //インスタンス生成
        facebookLabel = UILabel()
        // サイズ設定
        facebookLabel.frame.size.width = self.view.frame.width
        facebookLabel.frame.size.height = 48
        // 背景色
        facebookLabel.backgroundColor = .white
        facebookLabel.text = "ログアウト"
        facebookLabel.textAlignment = .center
        // 画像の中心を画面の中心に設定
        facebookLabel.center = CGPoint(x:screenWidth/2, y:screenHeight/2 + 720)
        
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(facebookLogputButton(tapGestureRecognizer:)))
        facebookLabel.isUserInteractionEnabled = true
        facebookLabel.addGestureRecognizer(tapGestureRecognizer)
        facebookLabel.translatesAutoresizingMaskIntoConstraints = false
        self.myScrollView.addSubview(facebookLabel)
        
        facebookLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        facebookLabel.topAnchor.constraint(equalTo: disappeareLabel.bottomAnchor, constant: 55.0).isActive = true
        facebookLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
    }
    
    
    
    @objc private func facebookLogputButton(tapGestureRecognizer: UITapGestureRecognizer){
        print("Logout")
        let alert: UIAlertController = UIAlertController(title: "ログアウト", message: "ログアウトしてもいいですか？", preferredStyle:  UIAlertControllerStyle.actionSheet)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            // UserDefaults にユーザーがログアウト状態であることを保存する。
            self.saveLoginStatus(str: "LoggedOut")
           
            let firebaseAuth = Auth.auth()

            do {
                // 以下の処理でfacebookからのlogoutしている。
                let loginManager = LoginManager()
                loginManager.logOut()
                
                try firebaseAuth.signOut()
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let UserInfo = storyboard.instantiateInitialViewController()
                self.present(UserInfo!, animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveLoginStatus(str: String){
        
        userDefaults.set(str, forKey: "UserStatus")
    }


    
    func navigationBar(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        let TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 64))
        let bgColor = UIColor.white
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
      
        let label = UILabel(frame: CGRect(x:0, y:0, width:80, height:20));
        label.text = "情報の編集";
        label.center = CGPoint(x:screenWidth/2, y:view.frame.origin.y + 40)

        self.view.addSubview(label);
        
  
        
        let done = UILabel(frame: CGRect(x:0, y:0, width:80, height:20));
        done.text = "完了";
        done.textColor = .red
        done.center = CGPoint(x:screenWidth-20, y:view.frame.origin.y + 40)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTranstion(tapGestureRecognizer:)))
        done.isUserInteractionEnabled = true
        done.addGestureRecognizer(tapGestureRecognizer)
        
        self.view.addSubview(done)
       //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
    }
    
    
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func screenTranstion(tapGestureRecognizer: UITapGestureRecognizer){

        sendSelfIntroduce()
        sendImageDate()
        saveImage()
        self.dismiss(animated: true, completion: nil)
//        let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
//        let UserInfo = storyboard.instantiateInitialViewController()
//        self.present(UserInfo!, animated: true, completion: nil)
    }
    
    //②保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "localData.png"
        print("==documentDirectoryFileURL:\(documentDirectoryFileURL)")

        
        // DocumentディレクトリのfileURLを取得
        if documentDirectoryFileURL != nil {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let path = documentDirectoryFileURL.appendingPathComponent(fileName)
            documentDirectoryFileURL = path
            print("-------------------")
            print("書き込むファイルのパス: \(String(describing: path))")
            print("-------------------")
        }
    }
    
    
    //③画像を保存する関数の部分
    func saveImage() {
        createLocalDataFile()
        //pngで保存する場合
        let pngImageData = UIImagePNGRepresentation(imageView.image!)
        do {
            try pngImageData!.write(to: documentDirectoryFileURL)
            //local端末にデータを保存
            userDefaults.set(documentDirectoryFileURL, forKey: "userImage")
            print("-------------------")
            print("サクセス！")
            print("-------------------")
        } catch {
            //エラー処理
            print("-------------------")
            print("エラー")
            print("-------------------")
        }
    }
    
    

    
    private func initImageView(){
        
        let image1:UIImage = UIImage(named:"userimage")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        imageView = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight * 0.25)
        
        // 角丸にする
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.myScrollView.addSubview(imageView)
        
        print("--------確認-----------")
        print(String(describing: UserDefaults.standard.url(forKey: "userImage")))
        print("--------確認-----------")
        
        //上で存在を確認した画像を「profileImageView」というイメージビューに値を代入する
        if UserDefaults.standard.url(forKey: "userImage") == nil {
            userDefaults.set(documentDirectoryFileURL, forKey: "userImage")
        }
        
        //（String型のfileWithPathのメソッドがSwiftにないので、一度URL型に変更）
        let fileURL = URL(fileURLWithPath: filePath).appendingPathComponent("localData.png")
 
        // UserDefaultsの情報を参照してpath指定に使う
        if appDelegate.photoLibraryImage != nil{
            imageView.image = appDelegate.photoLibraryImage
        }else{
            
            let path = String(describing: UserDefaults.standard.url(forKey: "userImage"))
            if let image = UIImage(contentsOfFile: fileURL.path) {
                let image = UIImageView(image: image)
                imageView.image = image.image
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                print("指定されたファイルが見つかりました")
            }else{
                print("指定されたファイルが見つかりません")
            }
        }
        
    }
    
    // ジェスチャーイベント処理
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("ジェスチャーイベント処理")
        
        // アルバムが利用可能かをチェック.
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
            self.showAlert(message: "アルバムは利用できません。")
            return
        }
        
        // アルバムを起動.
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        //        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    // Firebaseへ保存
    func sendImageDate(){
        
        let user = Auth.auth().currentUser
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("Users").child("image.jpg")
        //UIImagePNGRepresentationでUIImageをNSDataに変換
        if let data = UIImagePNGRepresentation(imageView.image! ){
            
            let reference = storageRef.child("images/" + (user?.uid)! + ".jpg")
            print("=========================================")
            print(reference) // gs://gokon-9a08a.appspot.com/images/9W7tZxxzcjN2sZ5Hn1AzgmXHgUK2.jpg
            
            //FIRStorageReference.putData(...)でアップロードしています。
            reference.putData(data, metadata: nil, completion: { metaData, error in
                
                // Fetch the download URL
                reference.downloadURL { url, error in
                    // Get the download URL for 'images/'
                    guard let downloadURL = url else {
                        print("失敗ーーーーーーーーーーーーーーーー！")
                        // Uh-oh, an error occurred!
                        return
                    }
                    print("成-------------------功！")
                    let deta = downloadURL.absoluteString
                    
                    if let uid = user?.uid{
                        self.ref?.child("Users").child(uid).updateChildValues(["image":deta])
                    }
                    
                }
                print(metaData as Any)
                print(error as Any)
            })
        }
    }
    
    func sendSelfIntroduce(){
        self.ref.child("Users").child(userUID).updateChildValues(["Introducing": selfIntroduction.text])
    }
    
    
    

}


// UIImagePickerController で必要なので実装（具体的な処理は不要なので中身はない）.
extension MyPageViewController: UINavigationControllerDelegate {}


extension MyPageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// カメラor写真で画像が選択された時などの処理を実装する.
extension MyPageViewController: UIImagePickerControllerDelegate {
    
    // カメラor写真で画像が選択された
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        // ユーザーがカメラで撮影した or 写真から選んだ、画像がある場合. varだったよ。
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("走っているよーーーーーーーーーーーーーーー")
            
            let cropViewController = CropViewController(croppingStyle: .circular, image: image)
            cropViewController.delegate = self as? CropViewControllerDelegate
            picker.present(cropViewController, animated: true, completion: nil)
        }
    }
}



extension MyPageViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        //加工した画像が取得できる
        print("OK")
        //AppDelegateファイルで定義している変数でデータを保持。
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.photoLibraryImage = image
        
        
        // 下の画面に戻る
        let storyboard: UIStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        cropViewController.present(UserInfo!, animated: true, completion: nil)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        // キャンセル時
        cropViewController.dismiss(animated: true, completion: nil)
        print("cancel")
    }
    
   
    
}

