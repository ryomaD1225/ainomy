//
//  FinalCheckViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2019/01/30.
//  Copyright © 2019 kishirinichiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

class FinalCheckViewController: UIViewController {

    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    var UserImage:UILabel!
    let button = UIButton()
    var TestView = UIView()
    var View = UIView()
    let sampleUILabel:UILabel = UILabel()
    
    let userDefaults = UserDefaults.standard
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 自分の性別を取得して参照する変数
    var genderInfo:String!
    // 自分の性別と逆の性別情報を参照する用変数
    var matchingPartner:String!
    // 選択した人数を参照する変数
    var selectedNumber:String!
    
    var Authenticity:String!
    var token:String!
    
    var userUID:String!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let user = Auth.auth().currentUser
        ref = Database.database().reference()
        userUID = user?.uid
        
        backButton()
        setTest()
        drowning()
        execution()
        selectedGender()
        educationLabel()
        readGender()
        
    }
    
    func backButton(){
        let screenWidth:CGFloat = view.frame.size.width
        TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 64))
        let bgColor = UIColor.white
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
        
        let items = UIBarButtonItem(barButtonHiddenItem: .Back, target: nil, action: #selector(self.myAction))
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "Ainomy")
        
        //ナビゲーションバーの左ボタンを追加
        navItem.leftBarButtonItem = items
        
        //ナビゲーションバーの左ボタンを追加
        navItem.rightBarButtonItem = UIBarButtonItem(title: "マイペ", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.goToMyPage))
        
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
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func goToMyPage(){
        let storyboard: UIStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }
    
    func setTest() {
        UserImage = UILabel()
        UserImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        UserImage.text = """
        この内容で相手を探します。
        よろしいですか？
        """
        UserImage.textAlignment = NSTextAlignment.center
        UserImage.numberOfLines = 2
        UserImage.sizeToFit()
        UserImage.center = self.view.center
        UserImage.frame.origin.y = navBar.bounds.height + 60
        self.view.addSubview(UserImage)
        
    }
    
    func drowning(){
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height

        View = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight/5.5))
        View.center = CGPoint(x:screenWidth/2, y:screenHeight/3)
        let bgColor = UIColor.cyan
        View.backgroundColor = bgColor
        self.view.addSubview(View)
        
        //右上と左下を角丸にする設定
        View.layer.cornerRadius = 10
        View.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func execution(){
       
        // サイズを変更する
        button.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        
//         任意の場所に設置する
        button.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
        
        // 文字色を変える
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        // 背景色を変える
        button.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1)
        
        // 枠の太さを変える
        button.layer.borderWidth = 1.0
        
        // 枠の色を変える
        button.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        button.layer.cornerRadius = 10
        
        // ボタンのタイトルを設定
        button.setTitle("決定", for:UIControlState.normal)
        
        // UIButtonとUILabelはフォントの大きさを変える時のメソッドが違う。
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Viewにボタンを追加
        self.view.addSubview(button)
        
        // buttonのtopAnchor(最上部)の位置は、BlueViewのbottomAnchor(最下部)の位置から20pt下
        button.topAnchor.constraint(equalTo: View.bottomAnchor, constant: 50.0).isActive = true
        // buttonのwidthAnchor(横幅)はBlueViewのwidthAnchor(横幅)と同じ
        button.widthAnchor.constraint(equalTo: View.widthAnchor).isActive = true
        // buttonのleadingAnchor(左端)はBlueViewのleadingAnchor(左端)と同じ
        button.leadingAnchor.constraint(equalTo: View.leadingAnchor).isActive = true
        //buttonの高さはViewの高さの0.35倍
        button.heightAnchor.constraint(equalTo: View.heightAnchor, multiplier: 0.35).isActive = true
        
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        
        print("押してるよ")
        let selectedNumber = readNumber()
        ref.child("selected").child(userUID!).setValue(["number": selectedNumber])
        print("押しているか？")
        self.matchDatabase()
        
    }
    
    func selectedGender(){
        print("===================selectedGenderLabel===================")
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        
        // サイズ設定
        sampleUILabel.frame.size.width = self.view.frame.width
        sampleUILabel.frame.size.height = 38
        // 背景色
        sampleUILabel.backgroundColor = UIColor.clear
        //        label.text = "男性"
        sampleUILabel.text = "やり直す"
        sampleUILabel.textAlignment = .center
        sampleUILabel.textColor = UIColor(white:0.35, alpha:1.0)
        // 画像の中心を画面の中心に設定
        sampleUILabel.center = CGPoint(x:screenWidth/2, y:button.frame.origin.y + 80)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textDidBeginEditing(tapGestureRecognizer:)))
        sampleUILabel.isUserInteractionEnabled = true
        sampleUILabel.addGestureRecognizer(tapGestureRecognizer)
        
        // テキストに下線を引く(https://logist3.com/swift-uilabel-uibutton-underline/)
        let attributeText = NSMutableAttributedString(string: sampleUILabel.text!)
        attributeText.addAttribute(
            NSAttributedString.Key.underlineStyle,
            value: NSUnderlineStyle.styleSingle.rawValue,
            range: NSMakeRange(0, sampleUILabel.text!.count)
        )
        
        self.sampleUILabel.attributedText = attributeText
        
        sampleUILabel.translatesAutoresizingMaskIntoConstraints = false
        // 画面に追加
        self.view.addSubview(sampleUILabel)
        
        // sampleUILabelをbuttonの真下に配置
        sampleUILabel.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        
        // buttonのtopAnchor(最上部)の位置は、BlueViewのbottomAnchor(最下部)の位置から50pt下
        sampleUILabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 50.0).isActive = true
        

    }
    
    @objc private func textDidBeginEditing(tapGestureRecognizer: UITapGestureRecognizer){
        print("you tatched")// handle begin editing event
        self.dismiss(animated: true, completion: nil)
    }
    
    func educationLabel(){

        //        let screenHeight:CGFloat = view.frame.size.height
        let label = UILabel()
        label.frame = CGRect(x:150, y:200, width:160, height:30)
        label.text = "人数  " + readNumber()
        label.textAlignment = .center
        label.font=UIFont.systemFont(ofSize: 22)
        // 画像の中心を画面の中心に設定
        label.center = CGPoint(x:0, y:0)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        // (7)
        label.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
        // (6)
        label.topAnchor.constraint(equalTo: View.topAnchor, constant: 80.0).isActive = true
    }
    
    func readNumber() -> String {
        
        let str: String = userDefaults.object(forKey: "numberOfPeople") as! String
        selectedNumber = userDefaults.object(forKey: "numberOfPeople") as? String
        return str
    }
    
    func readGender(){
        //UserDefaultsがの中身がnilじゃない場合の処理
        if UserDefaults.standard.object(forKey: "saveGender") != nil{
            genderInfo = userDefaults.object(forKey: "saveGender") as? String
            print(genderInfo)
            print("===================UserDafault性別========================")
        }
    }
    
    
    
//==============================ここからマッチング相手がいるかどうか確認する処理==================================
    func matchDatabase(){
       print(genderInfo!)
        print("中身の確認")
        let queue = DispatchQueue(label: "ainomy")
        if genderInfo! == "female"{
            appDelegate.matchingGender = "male"
            print("＝＝＝＝＝＝＝＝ここが走っているよ＝＝＝＝＝＝＝＝＝＝")//ここまではいけている
            let defaultPlace = self.ref.child("field/male").child(appDelegate.numberpeopleText)
            defaultPlace.observe(.value){(snap: DataSnapshot) in
                print("ここまでは走っているよ①")
                queue.sync {
                    for item in snap.children {
                        // https://qiita.com/koji-nishida/items/14fda04b586263a47e73
                        
                        print("ここまでは走っているよ②")
                        let child = (item as AnyObject).key as String
                        let snapshot = item as! DataSnapshot
                        let dict = snapshot.value as! [String: String]
                        self.Authenticity = dict["true"]
                        // https://hajihaji-lemon.com/smartphone/swift/%E3%83%A9%E3%83%99%E3%83%AB/
                        if let num = self.Authenticity {
                            self.appDelegate.facebookId = self.Authenticity!
                            print(num)
                            break // dictから取り出したvalueがnilでない時だけ実行される
                        }
                    }
                  
                }
               
                print("ここまでは走っているよ③")
                // self.appDelegate.facebookId = (snap.value! as AnyObject).description
                self.readToken()
                self.nextPage()
                print("＝＝＝＝fromAppDelegate.facebookIdの前＝＝＝＝")
                print(self.appDelegate.facebookId)
            }
            
        }else if genderInfo! == "male"{
            print("ここまで来ているか")
            appDelegate.matchingGender = "female"
            let defaultPlace = self.ref.child("field/female").child(appDelegate.numberpeopleText)
            defaultPlace.observe(.value){(snap: DataSnapshot) in
                queue.sync {
                print("ここまでは走っているよ①")
                for item in snap.children {
                        print("ここまでは走っているよ②")
                        let child = (item as AnyObject).key as String
                        let snapshot = item as! DataSnapshot
                        let dict = snapshot.value as! [String: String]
                        self.Authenticity = dict["true"]
                        
                        print("====test====\(self.Authenticity)")
                        
                       if let num = self.Authenticity {
                            self.appDelegate.facebookId = self.Authenticity!
                            print(num)
                               break// dicから取り出したvalueがnilでない時だけ実行される
                        }
                }
                }
                print("ここまでは走っているよ③")
                print("何回回しているのか")
                // self.appDelegate.facebookId = (snap.value! as AnyObject).description
                self.readToken()
                self.nextPage()
                print(self.appDelegate.facebookId)
            }
        }
        
    }
    
    func readToken(){
        token = userDefaults.object(forKey: "FCM_TOKEN") as? String
        ref.child("Users").child(userUID!).updateChildValues(["pushToken": token])
    }
    
    //相手がいない場合。NoneUser画面に遷移。いる場合MatchButtonh画面に遷移。
    func nextPage(){
        print(type(of:self.appDelegate.facebookId))
        print(appDelegate.facebookId)
        print("===============appDelegate.facebookId===============")
        // "true"のステータスを所持しているユーザがいない場合、
        if appDelegate.facebookId == "<null>" || appDelegate.facebookId == nil || appDelegate.facebookId == "nil"{
            // 自分の情報を”true"ステータスでデータベースに保存
            storeWaitInfo()
            print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
            // テスト①
            self.ref.child("backHome").updateChildValues([userUID!: "true"])
            
            let storyboard: UIStoryboard = UIStoryboard(name: "NoneUser", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
            
            
        }else{
            // "true"のステータスを所持しているユーザがいた場合、
            storeComingInfo()
            matchingUserInactive()
         
            // テスト②
            self.ref.child("backHome").updateChildValues([userUID!: appDelegate.facebookId!])
            self.ref.child("backHome").updateChildValues([appDelegate.facebookId!: userUID!])
            
            print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝相手は\(appDelegate.facebookId!)だよ＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
            let storyboard: UIStoryboard = UIStoryboard(name: "MatchButton", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
            
        }
    }
    
    //comingとしてデータをmatchへ保存。
    func storeComingInfo(){
    
        let matchingUser = appDelegate.facebookId!
 
        
        ref.child("match").child(userUID!).updateChildValues(["waiting": matchingUser])
        // そしてmatch/自分ユーザid/配下に、comingとして保存
        ref.child("match").child(userUID!).updateChildValues(["coming": userUID!])
        // 相手のmatch/マッチングユーザid/配下に、comingとして保存
        ref.child("match").child(matchingUser).updateChildValues(["waiting": matchingUser])
        let post = ["waiting":matchingUser,"coming":userUID]
        let childUpdates = ["/match/\(matchingUser)":post]
        ref.updateChildValues(childUpdates)
        
        
    ref.child("field").child(genderInfo).child(appDelegate.numberpeopleText).child(userUID!).updateChildValues(["false": userUID!])
    }
    
    //ここで自分がマッチした相手ユーザを非アクティブ状態にする。
    func matchingUserInactive(){
        let data = ["false":self.appDelegate.facebookId!]
        // マッチング相手が他の人とマッチが被らないようにするためにステータスをfalseへ変更する
        self.ref.child("field").child(appDelegate.matchingGender).child(appDelegate.numberpeopleText).child(appDelegate.facebookId!).setValue(data)
    }
    
    //fieldディレクトリ下に自分のデータを保存
    func storeWaitInfo(){
        // 自分の情報を”true"ステータスでデータベースに保存
    ref.child("field").child(genderInfo).child(appDelegate.numberpeopleText).child(userUID!).updateChildValues(["true": userUID!])
        // waitingとしても自分の情報を保存
        ref.child("match").child(userUID!).updateChildValues(["waiting": userUID!])
    }
    



 
}
