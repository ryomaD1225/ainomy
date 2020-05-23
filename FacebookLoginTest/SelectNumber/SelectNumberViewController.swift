//
//  SelectNumberViewController.swift
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



class SelectNumberViewController: UIViewController {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    var genderInfo:String!
    
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    var UserImage:UILabel!
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    var person: UIImageView!
    var twoPersons: UIImageView!
    var threePersons: UIImageView!
    var fourPersons: UIImageView!
    var selectedNumber:String!
    var test:String!
    var token:String!
    var voipToken:String!
    
    // ユーザが選択した人数を代入するための変数を定義
    var NumberOfPeople:String!
    
    var Authenticity:String!
    
    // マッチング相手のidを判断するための変数を定義
    var coming:String!
    var waiting:String!

    //マッチした相手ユーザがviewを開いた時の時間
    var matchTime:String!
    
    // ユーザーが指定した時間(仮) 分
    var userTimer:Int = 5
    
    // removeObserver用に定義
    var handler: UInt = 0
 

    override func loadView() {
        super.loadView()
        ref = Database.database().reference()
        print("======表示されるかテスト①=====")
        readGender()
        
        let queue = DispatchQueue(label: "confirming")
        queue.async {
            self.progressConfirmation()
        }
       
        
        // アプリ起動時・フォアグラウンド復帰時の通知を設定する
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SelectNumberViewController.onDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
      
    }
    
  
    func progressConfirmation(){
        
        ref.child("backHome").child((self.user?.uid)!).observe(.value, with: { (snapshot) in
            
            if snapshot.exists(){
                if snapshot.value as? String == "false" {
                    print("falseだった場合はここが走る\(snapshot.value as? String)")
                    let modal = UIViewController()
                    modal.modalPresentationStyle = .custom
                    modal.transitioningDelegate = self
                    self.present(modal, animated: true, completion: nil)
                }else if snapshot.value as? String == "true"{
                    print("trueだった場合はここが走る\(snapshot.value as? String)")
                    let storyboard: UIStoryboard = UIStoryboard(name: "NoneUser", bundle: nil)
                    let UserInfo = storyboard.instantiateInitialViewController()
                    self.present(UserInfo!, animated: true, completion: nil)
                }else{
                    print("実際マッチした相手のuidを取得して処理に走る。\(snapshot.value as? String)")
                    self.appDelegate.facebookId = snapshot.value as? String
                    self.ref.child("Users").child(self.appDelegate.facebookId).observe(.value, with: { (snapshot) in
                        
                        let items = snapshot.value as! [String: Any]
                        
                        self.appDelegate.matchingUserImagePath = items["image"]! as? String
                        self.appDelegate.matchingUserName = items["name"]! as? String
                        self.appDelegate.matchingUserAge = items["age"]! as? Int
                        self.appDelegate.matchingUserJob = items["companyName"]! as? String
                        self.appDelegate.matchingUserVoipId = items["playerid"]! as? String
                        // マッチング相手の時間を取得して変数へ代入して
                        self.matchTime = (items["time"]! as? String)
                        
                        // 現在時刻を取得して
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss"
                        
                        // 後から入ってきたユーザ用にこの画面を開いた時の時間を取得。
                        let displayTime = formatter.string(from: Date())
                        let matchTime = formatter.date(from:  self.matchTime)
                        let matched = formatter.date(from: displayTime)
                    
                        //ここで時間差を取得している。
                        let diff = Int(matched!.timeIntervalSince(matchTime!))
                        let myAbsoluteInt = 300 - diff
                        if(diff > 300 || diff <= 0){
                            self.userTimer = 0
                        }else{
                            self.userTimer = myAbsoluteInt
                        }
                        // マッチング画面でタイマーストップを押したか押していないか確かめる。
                      
                        //マッチング相手がいるページに遷移
                        let storyboard: UIStoryboard = UIStoryboard(name: "MatchUser", bundle: nil)
                        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
                        let second = storyboard.instantiateViewController(withIdentifier: "MatchUser") as? MatchUserImageViewController
                        second?.userTimer = self.userTimer
                        self.show(second!,sender: nil)
                        
                    })
                }
            }else{
                self.saveTimerData(str: "true")
                print("人数を選んでないからそのまま人数選択画面が表示されるよ\(snapshot)")
            }
        })
    }
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
         print("============ここが走る============")
        ref = Database.database().reference()

        
         navigationBar()
         personButton()
         twoPersonButton()
         threePersonButton()
         fourPersonButton()
         setTest(str: "あなたを含めた人数を選んでね")
         saveLoginStatus(str: "LoggedIn")
        saveVoipToken()
        // バックグランドからフォアグラウンドに移行時に走る
        NotificationCenter.default.addObserver(self, selector: #selector(SelectNumberViewController.viewWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        // バックグラウンドに移行時に走る
        NotificationCenter.default.addObserver(self, selector: #selector(SelectNumberViewController.viewDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
  
    // viewDidAppear:は完全に遷移が行われ、スクリーン上に表示された時に呼ばれる。(https://qiita.com/motokiee/items/0ca628b4cc74c8c5599d)
    override func viewDidAppear(_ animated: Bool) {
        print("======表示されるかテスト③=====")
        // ここのコメントアウトを消す
        // confirmingUser()
    }
    
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveData(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "numberOfPeople")
    }
    
    func saveVoipToken(){
        voipToken = userDefaults.object(forKey: "DEVICE_TOKEN") as? String
        ref.child("Users").child((user?.uid)!).updateChildValues(["deviceToken": voipToken])
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveLoginStatus(str: String){
        userDefaults.set(str, forKey: "UserStatus")
    }
    
    func saveTimerData(str: String){
        UserDefaults.standard.set(str, forKey: "stopTimer")
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readNumberOfPeople() -> String {
        let str: String = userDefaults.object(forKey: "numberOfPeople") as! String
        NumberOfPeople = str
        print("====userGender=====\(NumberOfPeople)")
        return str
    }
    
    
    // バックグランドからフォアグラウンドに移行時に走る
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("=====notification処理②=====")
        }
    }
    
    // バックグラウンドに移行時に走る
    @objc func viewDidEnterBackground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("=====notification処理③=====")
        }
    }
    
    // アプリ起動時・フォアグラウンド復帰時に行う処理
    @objc func onDidBecomeActive(_ notification: Notification?) {
        print("=====notification処理①=====")
        //================処理を早くするための実験=========================
        ref.child("backHome").child((self.user?.uid)!).observe(.value, with: { (snapshot) in
            
            // ===========①===========
            if snapshot.exists(){
                if snapshot.value as? String == "false" {
                    print("falseだった場合はここが走る\(snapshot.value as? String)")
                    let modal = UIViewController()
                    modal.modalPresentationStyle = .custom
                    modal.transitioningDelegate = self
                    self.present(modal, animated: true, completion: nil)
                }else if snapshot.value as? String == "true"{
                    print("trueだった場合はここが走る\(snapshot.value as? String)")
                    let storyboard: UIStoryboard = UIStoryboard(name: "NoneUser", bundle: nil)
                    let UserInfo = storyboard.instantiateInitialViewController()
                    self.present(UserInfo!, animated: true, completion: nil)
                }else{
                    print("実際マッチした相手のuidを取得して処理に走る。\(snapshot.value as? String)")
                    self.appDelegate.facebookId = snapshot.value as? String
                    
                    self.ref.child("Users").child(self.appDelegate.facebookId).observe(.value, with: { (snapshot) in
                        
                        let items = snapshot.value as! [String: Any]
                        // マッチング相手の時間を取得して変数へ代入して
                        self.matchTime = (items["time"]! as? String)
                        
                        // 現在時刻を取得して
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss"
                        
                        // 後から入ってきたユーザ用にこの画面を開いた時の時間を取得。
                        let displayTime = formatter.string(from: Date())
                        print("==========displayTime==========\(displayTime)============displayTime==========")
                        let matchTime = formatter.date(from:  self.matchTime)
                        print("==========matchTime==========\(matchTime)============matchTime==========")
                        let matched = formatter.date(from: displayTime)
                        print("==========matched==========\(matched)============matched==========")
                        //ここで時間差を取得している。
                        let diff = Int(matched!.timeIntervalSince(matchTime!))
                        if(diff < 60){ self.userTimer = 5 }
                        if(diff < 120 && diff > 60){ self.userTimer = 4}
                        if(diff < 180 && diff > 120){ self.userTimer = 3}
                        if(diff < 240 && diff > 180){ self.userTimer = 2}
                        if(diff < 300 && diff > 240){ self.userTimer = 1 }
                        if(diff > 300 || diff < 0){ self.userTimer = 0}
                        
                        //マッチング相手がいるページに遷移
                        let storyboard: UIStoryboard = UIStoryboard(name: "MatchUser", bundle: nil)
                        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
                        let second = storyboard.instantiateViewController(withIdentifier: "MatchUser") as? MatchUserImageViewController
                        second?.userTimer = self.userTimer
                        self.show(second!,sender: nil)
                        
                    })
                }
            }else{
                
                print("人数を選んでないからそのまま年数選択画面が表示されるよ\(snapshot)")
            }
            //================処理を早くするための実験=========================
   
        })
    }
    
   

    //Firebase で認証する
    func confirmingUser(){
        
        ref.child("backHome").child((self.user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // ===========①===========
            if snapshot.exists(){
                if snapshot.value as? String == "false" {
                    print("falseだった場合はここが走る\(snapshot.value as? String)")
                    let modal = UIViewController()
                    modal.modalPresentationStyle = .custom
                    modal.transitioningDelegate = self
                    self.present(modal, animated: true, completion: nil)
                }else if snapshot.value as? String == "true"{
                    print("trueだった場合はここが走る\(snapshot.value as? String)")
                    let storyboard: UIStoryboard = UIStoryboard(name: "NoneUser", bundle: nil)
                    let UserInfo = storyboard.instantiateInitialViewController()
                    self.present(UserInfo!, animated: true, completion: nil)
                }else{
                    print("実際マッチした相手のuidを取得して処理に走る。\(snapshot.value as? String)")
                    self.appDelegate.facebookId = snapshot.value as? String
                    
                    self.ref.child("Users").child(self.appDelegate.facebookId).observe(.value, with: { (snapshot) in
                        
                        let items = snapshot.value as! [String: Any]
                        // マッチング相手の時間を取得して変数へ代入して
                        self.matchTime = (items["time"]! as? String)
                        
                        // 現在時刻を取得して
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss"
                        
                        // 後から入ってきたユーザ用にこの画面を開いた時の時間を取得。
                        let displayTime = formatter.string(from: Date())
                        print("==========displayTime==========\(displayTime)============displayTime==========")
                        let matchTime = formatter.date(from:  self.matchTime)
                        print("==========matchTime==========\(matchTime)============matchTime==========")
                        let matched = formatter.date(from: displayTime)
                        print("==========matched==========\(matched)============matched==========")
                        //ここで時間差を取得している。
                        let diff = Int(matched!.timeIntervalSince(matchTime!))
                        if(diff < 60){ self.userTimer = 5 }
                        if(diff < 120 && diff > 60){ self.userTimer = 4}
                        if(diff < 180 && diff > 120){ self.userTimer = 3}
                        if(diff < 240 && diff > 180){ self.userTimer = 2}
                        if(diff < 300 && diff > 240){ self.userTimer = 1 }
                        if(diff > 300 || diff < 0){ self.userTimer = 0}
                        print("==========diff==========\(diff)============diff==========")
                        print("======self.userTimer======\(self.userTimer)=======self.userTimer=======")
                        print("=========④==========")
                        //マッチング相手がいるページに遷移
                        let storyboard: UIStoryboard = UIStoryboard(name: "MatchUser", bundle: nil)
                        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
                        let second = storyboard.instantiateViewController(withIdentifier: "MatchUser") as? MatchUserImageViewController
                        second?.userTimer = self.userTimer
                        self.show(second!,sender: nil)
                        
                    })
                }
            }else{
                self.saveTimerData(str: "true")
                print("人数を選んでないからそのまま人数選択画面が表示されるよ\(snapshot)")
            
            }
        })
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
    
    
    private func personButton(){
        
        let image1:UIImage = UIImage(named:"one")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        person = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        person.frame = rect;
        
        // 画像の中心を画面の中心に設定
//        person.center = CGPoint(x:screenWidth/4, y:screenHeight/4)
        person.center = CGPoint(x:screenWidth/4 - 5, y:screenHeight/4 + 100)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numberOne(tapGestureRecognizer:)))
        person.isUserInteractionEnabled = true
        person.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(person)
        
        // 設定済みをマーク.
        self.selectedNumber = "1人"

    }
    

    
    // ジェスチャーイベント処理
    @objc func numberOne(tapGestureRecognizer: UITapGestureRecognizer){
        // self.appDelegate.numberpeopleText はぶっちゃけ必要ないかもしれないので、以後確認必須
        appDelegate.numberpeopleText = "1人"
        saveData(str: appDelegate.numberpeopleText)
        print("1人選択")
        finalconfirmation()
//        matchDatabase()
        
    }
    
    private func fourPersonButton(){
        let image1:UIImage = UIImage(named:"two")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        person = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        person.frame = rect;
        
        // 画像の中心を画面の中心に設定
        //person.center = CGPoint(x:screenWidth * 0.75, y:screenHeight/4)
        person.center = CGPoint(x:screenWidth * 0.75 + 5, y:screenHeight/4 + 100)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numberFour(tapGestureRecognizer:)))
        person.isUserInteractionEnabled = true
        person.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(person)
        
        // 設定済みをマーク.
        self.selectedNumber = "2人"
        
    }
    
    // ジェスチャーイベント処理
    @objc func numberFour(tapGestureRecognizer: UITapGestureRecognizer){
        appDelegate.numberpeopleText = "2人"
        saveData(str: appDelegate.numberpeopleText)
        print("2人選択")
        finalconfirmation()
//        matchDatabase()
        
    }
    
    private func twoPersonButton(){
        let image1:UIImage = UIImage(named:"tree")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        person = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        person.frame = rect;
        
        // 画像の中心を画面の中心に設定
//        person.center = CGPoint(x:screenWidth/4, y:screenHeight * 0.75)
        person.center = CGPoint(x:screenWidth/4 - 5, y:screenHeight * 0.75 - 100)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numberTwo(tapGestureRecognizer:)))
        person.isUserInteractionEnabled = true
        person.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(person)
        
        // 設定済みをマーク.
        self.selectedNumber = "3人"
        
    }
    
    // ジェスチャーイベント処理
    @objc func numberTwo(tapGestureRecognizer: UITapGestureRecognizer){
        appDelegate.numberpeopleText = "3人"
        saveData(str: appDelegate.numberpeopleText)
        print("3人選択")
        finalconfirmation()
//        matchDatabase()
        
    }
    
    private func threePersonButton(){
        let image1:UIImage = UIImage(named:"fow")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        person = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        person.frame = rect;
        
        // 画像の中心を画面の中心に設定
//        person.center = CGPoint(x:screenWidth * 0.75, y:screenHeight * 0.75)
        person.center = CGPoint(x:screenWidth * 0.75 + 5, y:screenHeight * 0.75 - 100)
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(numberThree(tapGestureRecognizer:)))
        person.isUserInteractionEnabled = true
        person.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(person)
        
        // 設定済みをマーク.
        self.selectedNumber = "4人"
        
    }
    
    // ジェスチャーイベント処理
    @objc func numberThree(tapGestureRecognizer: UITapGestureRecognizer){
        appDelegate.numberpeopleText = "4人"
        saveData(str: appDelegate.numberpeopleText)
        print("4人選択")
        finalconfirmation()
//        matchDatabase()
        
    }
    
   
    
    func navigationBar(){
        
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)

        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "Ainomy")
        
        //ナビゲーションバーの左ボタンを追加
        navItem.rightBarButtonItem = UIBarButtonItem(title: "マイペ", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.myAction))
        
        //ナビゲーションバーにアイテムを追加
        navBar.pushItem(navItem, animated: true)
        // Viewにボタンを追加
        self.view.addSubview(navBar)
    }
    
    
    func matchDatabase(){
        if genderInfo! == "female"{
            appDelegate.matchingGender = "male"
            print("＝＝＝＝＝＝＝＝ここが走っているよ＝＝＝＝＝＝＝＝＝＝")//ここまではいけている
            
          
            let defaultPlace = self.ref.child("field/male").child(appDelegate.numberpeopleText)
            defaultPlace.observe(.value){(snap: DataSnapshot) in
                print("ここまでは走っているよ①")
                for item in snap.children {
                    print("ここまでは走っているよ②")
                    let child = (item as AnyObject).key as String
                    let snapshot = item as! DataSnapshot
                    let dict = snapshot.value as! [String: String]
                    self.Authenticity = dict["true"]
                    if let num = self.Authenticity {
                        self.appDelegate.facebookId = self.Authenticity!
                        break // dicから取り出したvalueがnilでない時だけ実行される
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
            appDelegate.matchingGender = "female"
            let defaultPlace = self.ref.child("field/female").child(appDelegate.numberpeopleText)
            defaultPlace.observe(.value){(snap: DataSnapshot) in
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
                        break // dicから取り出したvalueがnilでない時だけ実行される
                    }
                    print("ここまでは走っているよ③")
                    print("何回回しているのか")
                }
               
                
            // self.appDelegate.facebookId = (snap.value! as AnyObject).description
                self.readToken()
                self.nextPage()
                print(self.appDelegate.facebookId)
            }
        }
        
    }
    
    func finalconfirmation(){
        let storyboard: UIStoryboard = UIStoryboard(name: "FinalCheck", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }

    
    //相手がいない場合。NoneUser画面に遷移。いる場合MatchButtonh画面に遷移。
    func nextPage(){
         print(type(of:self.appDelegate.facebookId))
         print(appDelegate.facebookId)
        //手直しした。
        if appDelegate.facebookId == "<null>" || appDelegate.facebookId == nil || appDelegate.facebookId == "nil"{
            storeWaitInfo()
            print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝相手はNilだよ＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
            // テスト①
            self.ref.child("backHome").updateChildValues([(self.user?.uid)!: "true"])
            
            let storyboard: UIStoryboard = UIStoryboard(name: "NoneUser", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
            
        }else{
            
            storeComingInfo()
            matchingUserInactive()
            // テスト②
            self.ref.child("backHome").updateChildValues([(self.user?.uid)!: appDelegate.facebookId!])
            self.ref.child("backHome").updateChildValues([appDelegate.facebookId!: (self.user?.uid)!])
            print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝相手は\(appDelegate.facebookId!)だよ＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
            let storyboard: UIStoryboard = UIStoryboard(name: "MatchButton", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
        }
    }
    
    
    //fieldディレクトリ下に自分のデータを保存
    func storeWaitInfo(){
        ref.child("field").child(genderInfo).child(appDelegate.numberpeopleText).child((user?.uid)!).updateChildValues(["true": user?.uid as Any])
        ref.child("match").child((user?.uid)!).updateChildValues(["waiting": user?.uid as Any])
        }
    
    //comingとしてデータをmatchへ保存。
    func storeComingInfo(){
        let userid = user?.uid
        print("userid：\(String(describing: userid))")
        print("appDelegate.facebookId：\(appDelegate.facebookId!)")
//        ref.child("match/\(appDelegate.facebookId!)").updateChildValues(["coming": userid!])
//        ref.child("match").child((user?.uid)!).updateChildValues(["coming": user?.uid as Any])
//        ref.child("match").child((user?.uid)!).updateChildValues(["waiting": appDelegate.facebookId!])
//        ref.child("field").child(genderInfo).child(appDelegate.numberpeopleText).child((user?.uid)!).updateChildValues(["false": user?.uid as Any])
    }
    
    //ここで自分がマッチした相手ユーザを非アクティブ状態にする。
    func matchingUserInactive(){
        let data = ["false":self.appDelegate.facebookId!]
self.ref.child("field").child(self.appDelegate.matchingGender).child(self.appDelegate.numberpeopleText).child(appDelegate.facebookId!).setValue(data)
        }

    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readToken(){
        token = userDefaults.object(forKey: "FCM_TOKEN") as? String
        ref.child("Users").child((user?.uid)!).updateChildValues(["pushToken": token])
    
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readGender(){
        //UserDefaultsがの中身がnilじゃない場合の処理
        if UserDefaults.standard.object(forKey: "saveGender") != nil{
        genderInfo = userDefaults.object(forKey: "saveGender") as? String
        print(genderInfo)
        print("===================UserDafault性別========================")
        }
    }
    
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func myAction(){
        let storyboard: UIStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }

}

extension SelectNumberViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SeeYouTomorrowController(presentedViewController: presented, presenting: presenting)
    }
}
