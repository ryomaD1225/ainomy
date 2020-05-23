//
//  MatchUserImageViewController.swift
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
import FirebaseUI
//カメラと用
import AVFoundation
import CallKit
import PushKit
import SkyWay
// Voip通知用
import OneSignal
// 画面遷移アニメーション用ライブラリ
import Hero

//電話の状態が変わる場合システムからXCProviderDelegateを通じて知らせます。
//プログラマーはこのDelegateを実装することでそれぞれの状態をアプリに反映することが可能です。
//そして、その状態を正しく処理したことをシステムに知らせることで、システムもその状態をシステム全体に反映することになります。
// class MatchUserImageViewController: UIViewController, CXProviderDelegate
class MatchUserImageViewController: UIViewController {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var peerId:String!
    var selectedUserName: String!
    var selectedUserage:Int!
    var selectedUserId:String!
    var userJob:String!
    var userSelf:String!
    
    var nameLabel = UILabel()
    var ageLabel = UILabel()
    var userWorkPlace = UILabel()
    
    // ボタンのインスタンス生成
    let makeConnection = UIButton()
    let disConnection = UIButton()
    
    var first:String!
    // タイマー
    var timer : Timer!
    
    // ユーザーが指定した時間(仮) 分
    var userTimer:Int!
    var count = 0
    
    // 時間を表示する為のラベル
    var timeLabel:UILabel!
    var secondLabel:UILabel!
    
    //マッチした相手ユーザがviewを開いた時の時間
     var matchTime:String!
    
    let userDefaults = UserDefaults.standard
    // ユーザの性別を代入する変数
    var genderInfo:String!
    
    // ユーザが選択した人数を代入するための変数を定義
    var NumberOfPeople:String!
    
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
  
    var imagePath:String!
    var scale:CGFloat = 1.0
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    var image1:UIImage!
    var imageView = UIImageView()
    
    var label = UILabel()
    var TestView = UIView()
    
    var line = CAShapeLayer()
    
    var testSecond = UILabel()
    
    var timerMinute = UILabel()
    var timerSecond = UILabel()
    var limitedTimer:Timer!
    let whiteView = UIView()
    var startTime = Date()
    var userUID:String!
    
  
    override func loadView() {
        super.loadView()

        ref = Database.database().reference()
         userUID = user?.uid
        NavigationController()
        whiteViewPrepare()
        mainLabel()
        drowning()
        onCallButton()
//        disCallButton()
        makingLine()
        
       
        if appDelegate.matchingUserImagePath == nil{
                   print(appDelegate.matchingUserImagePath)
            print("============マッチング相手の情報がない場合にここが走る=============")
            
            ref.child("Users").child(appDelegate.facebookId).observe(.value, with: { (snapshot) in
                
                let items = snapshot.value as! [String: Any]
                
                print("============ここまでいけてる================")
                //①マッチング相手のpeeridを取得する
//                self.peerId = items["peerId"]! as? String
//                self.appDelegate.peerId = items["peerId"]! as? String
                 print("============peerId================")
                self.selectedUserName = items["name"]! as? String
                self.appDelegate.matchingUserName = items["name"]! as? String
                print("============selectedUserName================")
                self.imagePath = items["image"]! as? String
                self.appDelegate.matchingUserImagePath = items["image"]! as? String
         
                 print("============magePath================")
                self.selectedUserage = items["age"]! as? Int
                self.appDelegate.matchingUserAge = items["age"]! as? Int
                 print("============selectedUserage================")
                self.userJob = items["companyName"]! as? String
                self.appDelegate.matchingUserJob = items["companyName"]! as? String
                 print("============userJob================")
                self.selectedUserId = items["playerid"]! as? String
                self.appDelegate.matchingUserVoipId = items["playerid"]! as? String
                print("=============userInroducing===========")
                if let nilCheckitems = ["Introducing"] as? String {
                    print("自己紹介を書いている場合はこちらが走ります")
                    self.appDelegate.userIntroducing = items["Introducing"]! as? String
                }else{
                    print("自己紹介を書いていない場合はこちらが走ります")
                    self.appDelegate.userIntroducing = " "
                }
               
                
                self.loadImage()
                self.matchingName()
                self.matchingAge()
                self.matchingJob()
            })
        }else{
            NavigationController()
            mainLabel()
            drowning()
            onCallButton()
            makingLine()
            print("============既にマッチング相手の情報がある場合にここが走る=============")

            self.selectedUserName = self.appDelegate.matchingUserName
            self.imagePath = self.appDelegate.matchingUserImagePath
            self.selectedUserage = self.appDelegate.matchingUserAge
            self.userJob = self.appDelegate.matchingUserJob
            
            self.loadImage()
            self.matchingName()
            self.matchingAge()
            self.matchingJob()
            
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        NavigationController()
        readGender()
        readNumberOfPeople()
        
        // 電話機能周り
        //provider.setDelegate(self, queue: nil)
    
       
    }
    
    
    func NavigationController(){
        
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "Ainomy")
        
        //ナビゲーションバーにアイテムを追加
        navBar.pushItem(navItem, animated: true)
        // Viewにボタンを追加
        self.view.addSubview(navBar)
    }
    
    func mainLabel() {
        
        nameLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nameLabel.text = "相飲みのお相手"
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.numberOfLines = 2
        nameLabel.sizeToFit()
        nameLabel.center = self.view.center
        nameLabel.frame.origin.y = navBar.bounds.height + 50
        self.view.addSubview(nameLabel)
        
    }
    
    func whiteViewPrepare(){
        whiteView.backgroundColor = .white
        view.addSubview(whiteView)
    }
    
    func drowning(){
        
        let screenWidth:CGFloat = self.view.frame.size.width
        let screenHeight:CGFloat = self.view.frame.size.height
        TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight*0.75))
        TestView.center = CGPoint(x:screenWidth/2,y:screenHeight/2)
        
        let bgColor = UIColor.blue
        TestView.backgroundColor = bgColor
        print("ーーーーーーーーーTestViewーーーーーーーーー")
        self.view.addSubview(TestView)
        
        //右上と左下を角丸にする設定
        TestView.layer.cornerRadius = 10
        TestView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        print("ーーーーーーーーーTestViewーーーーーーーーー")
        
    
    }
    
    func loadImage(){
        image1 = UIImage(named:"userimage")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        imageView.image = image1
        // 画面の横幅を取得
        let screenWidth:CGFloat = self.view.frame.size.width
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        // 元の真四角のやつ
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale-200, height:height*scale-200)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;
        // 画像の中心を画面の中心に設定
        
        imageView.center = CGPoint(x:self.view.frame.size.width/2, y:TestView.frame.origin.y + 130 )
        
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        print("\(self.appDelegate.facebookId!)：self.appDelegate.facebookId!")
        let storageref = Storage.storage().reference(forURL: "gs://facebooklogintest-3501b.appspot.com").child("images/\(String(describing: self.appDelegate.facebookId!)).jpg")
        print(storageref)
        //画像をセット
        imageView.sd_setImage(with: storageref)
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.hero.id = "UserImage"
        imageView.addGestureRecognizer(tapGestureRecognizer)
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        print("==============ここまで走っているよ①================")
     
    }
    
    // ライブラリHeroで画像を大きくしながら画面遷移させる
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let matchDetail = MatchDetailViewController()
        matchDetail.hero.isEnabled = true
        matchDetail.testTime = count
        present(matchDetail, animated: true, completion: nil)
    }
  
    
    
    func matchingName(){

        label = UILabel()
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = selectedUserName
        label.font = UIFont.systemFont(ofSize: 23)
        label.textAlignment = .center
        // 画像の中心を画面の中心に設定
         label.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        label.hero.id = "name"
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10.0).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
 
    }
    
    func matchingAge(){
           print("==========うりゃ===============")
        ageLabel = UILabel()
        ageLabel.backgroundColor = .green
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.text = "\(selectedUserage!)" + " 歳"
        ageLabel.font = UIFont.systemFont(ofSize: 23)
        ageLabel.textAlignment = .center
        // 画像の中心を画面の中心に設定
        ageLabel.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        ageLabel.hero.id = "age"
        self.view.addSubview(ageLabel)
     
        ageLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10.0).isActive = true
        ageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        print("==============ここまで走っているよ④================")
    }
    
    func matchingJob(){
        userWorkPlace = UILabel()
        userWorkPlace.backgroundColor = .green
        userWorkPlace.translatesAutoresizingMaskIntoConstraints = false
        userWorkPlace.text = userJob
        userWorkPlace.font = UIFont.systemFont(ofSize: 23)
        userWorkPlace.textAlignment = .center
        // 画像の中心を画面の中心に設定
        userWorkPlace.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        userWorkPlace.hero.id = "job"
        self.view.addSubview(userWorkPlace)
        
        userWorkPlace.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10.0).isActive = true
        userWorkPlace.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    // 線を引くメソッド
    func makingLine(){
        line = CAShapeLayer()
        line.strokeColor = UIColor.black.cgColor
        line.lineWidth = 2.0
        
        let horizonalLine = UIBezierPath()
        horizonalLine.move(to: CGPoint(x:self.view.frame.width*0.15,y:makeConnection.frame.origin.y - 55)) //始点
        horizonalLine.addLine(to:CGPoint(x:self.view.frame.width*0.85 - 10,y:makeConnection.frame.origin.y - 55))   //終点
        horizonalLine.close()  //線を結ぶ

        line.path = horizonalLine.cgPath
        self.view.layer.addSublayer(line)
        
    }
    
    func onCallButton(){
    
        // サイズを変更する
        makeConnection.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        // 任意の場所に設置する
        makeConnection.layer.position = CGPoint(x: self.view.frame.width * 0.25, y:self.view.frame.height * 0.75)
        
        // 文字色を変える
        makeConnection.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        // 背景色を変える
        makeConnection.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1)
        
        // 枠の太さを変える
        makeConnection.layer.borderWidth = 1.0
        
        // 枠の色を変える
        makeConnection.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        makeConnection.layer.cornerRadius = 10
        
        // ボタンのタイトルを設定
        makeConnection.setTitle("電話をする", for:UIControlState.normal)
        
        // タップされたときのaction
        makeConnection.addTarget(self,
                                 action: #selector(callTapped(sender: )),
                                 for: .touchUpInside)
        
        makeConnection.translatesAutoresizingMaskIntoConstraints = false
        
        // Viewにボタンを追加
        self.view.addSubview(makeConnection)
        // 緑のビューの高さは、青のビューの高さと同じ大きさ
        makeConnection.heightAnchor.constraint(equalTo: TestView.heightAnchor, multiplier: 0.10).isActive = true
        // makeConnectionビューの幅は、TestViewの幅の4/5
        makeConnection.widthAnchor.constraint(equalTo: TestView.widthAnchor, multiplier: 0.90).isActive = true
        makeConnection.topAnchor.constraint(equalTo: TestView.bottomAnchor, constant: -70.0).isActive = true
        makeConnection.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
    }
    
    // 発電ボタンをクリック
    @objc func callTapped(sender : AnyObject) {
        // タイマーを止める
        timer.invalidate()
        saveTimerData(str: "false")
        // この画面に遷移したら電話がつながるように処理をする
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "Disconnection")
        present(nextView, animated: false, completion: nil)

    }
    
    func saveTimerData(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "stopTimer")
        
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
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readNumberOfPeople(){
        
        if userDefaults.object(forKey: "numberOfPeople") != nil{
            let str: String = userDefaults.object(forKey: "numberOfPeople") as! String
            NumberOfPeople = str
            print("====userGender=====\(NumberOfPeople)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        // タイマーが止められていなかった時の処理
        let value = UserDefaults.standard.object(forKey: "stopTimer") as! String
        if value == "true"{
            self.counting()
        }else{
            print("Timerは止まっているよ")
            timerLabel()
        }
    }
    
    func timerLabel(){
        timeLabel = UILabel()
        timeLabel.text = "00"
        timeLabel.textColor = UIColor.lightGray
        timeLabel.frame = CGRect(x:15,y:8,width:30,height:50)
        timeLabel.font = UIFont.systemFont(ofSize: 50)
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        timeLabel.bottomAnchor.constraint(equalTo: makeConnection.topAnchor, constant: -50.0).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: TestView.leadingAnchor, constant:220.0).isActive = true
        
        secondLabel = UILabel()
        secondLabel.text = ":"
        secondLabel.textColor = UIColor.lightGray
        secondLabel.frame = CGRect(x:20,y:8,width:30,height:50)
        secondLabel.font = UIFont.systemFont(ofSize: 50)
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondLabel)
        secondLabel.bottomAnchor.constraint(equalTo: makeConnection.topAnchor, constant: -55.0).isActive = true
        secondLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant:20.0).isActive = true
        // countは300とか360tt感じになる

        
         testSecond = UILabel()
        testSecond.text = "00"
        testSecond.textColor = UIColor.lightGray
        testSecond.frame = CGRect(x:50,y:8,width:30,height:50)
        testSecond.font = UIFont.systemFont(ofSize: 50)
        testSecond.translatesAutoresizingMaskIntoConstraints = false
        testSecond.textAlignment = .center
        view.addSubview(testSecond)
        testSecond.bottomAnchor.constraint(equalTo: makeConnection.topAnchor, constant: -55.0).isActive = true
        testSecond.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant:20.0).isActive = true
    }
    // TimerのtimeIntervalで指定された秒数毎に呼び出されるメソッド
    @objc func updateLabel(){
        
        if count > 60 {
//            let minuteCount = count / 60
            let minute = (Int)(fmod((Double(count/60)), 60))
            let second = (Int)(fmod(Double(count), 60))
            // %02d： ２桁表示、0で埋める
            let sMinute = String(format:"%02d", minute)
            let sSecond = String(format:"%02d", second)
            
            timeLabel.text = String(sMinute)
            testSecond.text = String(sSecond)
            secondLabel.text = ":"
        } else if count < 60 && count > 0{
            let second = (Int)(fmod(Double(count), 60))
            // %02d： ２桁表示、0で埋める
            let sSecond = String(format:"%02d", second)
            timeLabel.text = "00"
            testSecond.text = String(sSecond)
            secondLabel.text = ":"
        }else if count == 0 || count < 0 {
            // タイマーを止める
            timer.invalidate()
            // アラートを表示する
            print("nilになっているユーザのuidを表示：\(user?.uid)")
            ref.child("backHome").updateChildValues([userUID!: "false"])
            showAlert(message: " 5分経ったのでマッチングを解除します。")
            let data = ["false":user?.uid]
            // そしてマッチング相手のステータスをアクティブにする
            ref.child("field").child(genderInfo).child(NumberOfPeople).child((user?.uid)!).setValue(data)
            
        }
        count -= 1
    }
    
    
    
    func counting(){
        print("=========ドッチ=========")
        // 分
        timeLabel = UILabel()
        timeLabel.frame = CGRect(x:15,y:8,width:30,height:50)
        timeLabel.font = UIFont.systemFont(ofSize: 50)
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        timeLabel.bottomAnchor.constraint(equalTo: makeConnection.topAnchor, constant: -50.0).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: TestView.leadingAnchor, constant:220.0).isActive = true
        
        // :
        secondLabel = UILabel()
        secondLabel.frame = CGRect(x:20,y:8,width:30,height:50)
        secondLabel.font = UIFont.systemFont(ofSize: 50)
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondLabel)
        secondLabel.bottomAnchor.constraint(equalTo: makeConnection.topAnchor, constant: -55.0).isActive = true
        secondLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant:20.0).isActive = true
        // countは300とか360tt感じになる
//        count = userTimer * 60
        count = userTimer
        
        // 秒
        testSecond = UILabel()
        testSecond.frame = CGRect(x:50,y:8,width:30,height:50)
        testSecond.font = UIFont.systemFont(ofSize: 50)
        testSecond.translatesAutoresizingMaskIntoConstraints = false
        testSecond.textAlignment = .center
        view.addSubview(testSecond)
        testSecond.bottomAnchor.constraint(equalTo: makeConnection.topAnchor, constant: -55.0).isActive = true
        testSecond.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant:20.0).isActive = true
        
        // 0.01秒ごとにupdateLabel()を呼び出す
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        
    }
    
        // アラート表示を行う機能.
        override func showAlert(message: String) {
            // UIAlertControllerのインスタンスを作成します.
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            // OKボタンを追加します.
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            // OKボタンを押されたら、アラートダイアログを非表示にします.
            alert.dismiss(animated: true, completion: nil)
                self.moveToselectNumber()
                })
                // アラートダイアログを表示します.
                self.present(alert, animated: true)
            }
    
        //人数選択画面に画面遷移する処理
        func moveToselectNumber(){
            let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
        }
    
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        
            whiteView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        }
    

    
}

// voip通知UIインスタンスを生成
//        let transaction = CXTransaction(action: CXStartCallAction(call: UUIDs, handle: CXHandle(type: .generic, value: "ainomy")))
//
//        self.controller.request(transaction){ error in
//            // UIインスタンス生成失敗したら〜
//            if let error = error {
//                print("Error requesting transaction: \(error)")
//            } else {
//                print("Requested transaction successfully") // Error Domain=com.apple.CallKit.error
//                //UIインスタンス生成成功したら、①skywayシグナリングサーバへ通信を行う
//                self.setup()
//                // ここで電話をかけている！ -> callPeerIDSelectDialogでかけたい相手のpeerIdを取得
//                // self.call(targetPeerId: self.peerId)
//
//            }
//        }


//func disCallButton(){
//
//    // サイズを変更する
//    disConnection.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
//
//    // 任意の場所に設置する
//    disConnection.layer.position = CGPoint(x: self.view.frame.width * 0.75, y:self.view.frame.height * 0.75)
//
//    // 文字色を変える
//    disConnection.setTitleColor(UIColor.white, for: UIControlState.normal)
//
//    // 背景色を変える
//    disConnection.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1)
//
//    // 枠の太さを変える
//    disConnection.layer.borderWidth = 1.0
//
//    // 枠の色を変える
//    disConnection.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
//
//    // 枠に丸みをつける
//    disConnection.layer.cornerRadius = 25
//
//    // ボタンのタイトルを設定
//    disConnection.setTitle("切電する", for:UIControlState.normal)
//
//    // タップされたときのaction
//    disConnection.addTarget(self,
//                            action: #selector(disCallTapped(sender:)),
//                            for: .touchUpInside)
//
//    // Viewにボタンを追加
//    self.view.addSubview(disConnection)
//}
//
////切電ボタン
//@objc func disCallTapped(sender : AnyObject) {
//    let endCallAction = CXEndCallAction(call: UUIDs)
//    print("UUIDs③: \(UUIDs)")
//    let transaction2 = CXTransaction(action: endCallAction)
//
//    self.controller.request(transaction2) { (error) in
//
//        if let error = error {
//            print("self.UUID:\(self.UUIDs)")
//            print(error)
//        } else {
//            //ここで電話を終了している！
//            print("=================切電===================")
//            self.mediaConnection?.close()//①
//        }
//    }
//}
//
////変数providerへCXProviderのインスタンスを定義。電話機能周りのやつ callkitのために追加
////このクラスのインスタンスをreportNewIncomingCallメソッドを呼び出すことで着信画面を表示している。
//let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "ainomy"))
//let UUIDs = UUID()
//let callUpdate = CXCallUpdate()
//let controller = CXCallController()
//
////callkitのために追加 providerDidResetはCXProviderDelegateのために必要
//func providerDidReset(_ provider: CXProvider) { }
//
////ユーザーが着信画面から電話を受け取るとここのDelegateが呼びだ出される。
//func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
//    print("=================電話を取った時===================")
//    //タイマーを止める処理
//    timer.invalidate()
//    //(fulfill())ここでシステムが電話を受けった状態と認識する。
//    action.fulfill()
//}
//
////着信をリジェクトした場合か切電した時に呼ばれる。callkitのために追加(通話拒否・終了)
////ネイティブ通話画面から通話を終了されたときに呼ばれるデリゲート
//func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
//    print("your UUID②: \(UUIDs)")//②
//    print("=================電話を切った時===================")
//
//    self.mediaConnection?.close()//②
//    action.fulfill()//(fulfill())切断する際も同じくactionの「fulfill」メソッドを呼び出すことで処理が終了できたことをOSに知らせる。
//
//}
//
//func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
//    print("Requested transaction successfully②")
//    // Signal to the system that the action has been successfully performed.
//    //        action.fail()
//    //        action.fulfill()
//}
//
////トークンが無効になった場合は以下のDelegateが呼ばれる
//func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
//    NSLog("didInvalidatePushTokenForType")
//}
//
