//
//  NoneUserViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/06.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

// テスト②
//self.ref.child("backHome").updateChildValues([(self.user?.uid)!: appDelegate.facebookId!])
//self.ref.child("backHome").updateChildValues([appDelegate.facebookId!: (self.user?.uid)!])

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import Lottie

class NoneUserViewController: UIViewController {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    // ボタンのインスタンス生成
    let button = UIButton()
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    
    //マッチした相手ユーザがviewを開いた時の時間
    var matchTime:String!
    
    // ユーザーが指定した時間(仮) 分
    var userTimer:Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        getUserId()
        backButton()
        showAnimation()
        nextButton()
    }
    
    func showAnimation() {
        print("showAnimation()")
        let animationView = LOTAnimationView(name: "Animation")
        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        //        animationView.backgroundColor = UIColor.blue
        animationView.center = self.view.center
        //http://www.tokoro.me/posts/lottie-ios-1/
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1
        view.addSubview(animationView)
        animationView.play()
    }
    
    func backButton(){
        _ = UIBarButtonItem(barButtonHiddenItem: .Back, target: nil, action: #selector(self.myAction))
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "Ainomy")
        
        //ナビゲーションバーの左ボタンを追加
        navItem.rightBarButtonItem = UIBarButtonItem(title: "マイペ", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.myAction))
        
        
        //ナビゲーションバーにアイテムを追加
        navBar.pushItem(navItem, animated: true)
        // Viewにボタンを追加
        self.view.addSubview(navBar)
        print("===============backbutton===============")
    }
    
    //UINavigationBarのボタン(MyPage画面に遷移)
    @objc func myAction(){
        print("できたよ")
        let storyboard: UIStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }
    
    //③相手がいるときと、いないときで遷移画面が違う。
    func nextButton(){
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        // サイズを変更する
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        // 任意の場所に設置する
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
        button.layer.cornerRadius = 25
        
        // ボタンのタイトルを設定
        button.setTitle("相手いない", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
        
    }
    
    //ここを新しく作った。がviewgdidload時に呼び出されるからその後のボタンを押した時の処理が少し早くなるか検証しないといけない。
    func getUserId(){
        if appDelegate.facebookId == nil || appDelegate.facebookId! == "<null>"{
            let defaultPlace = ref.child("match").child((self.user?.uid)!).child("coming")
            defaultPlace.observe(.value){(snap: DataSnapshot) in self.appDelegate.facebookId = (snap.value! as AnyObject).description
                print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝相手がいないか確認：\(String(describing: self.appDelegate.facebookId))＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
            
            }
        }
    }
    
    //ボタンを押した時の処理
    @objc func buttonTapped(sender : AnyObject) {
        
        print(type(of: appDelegate.facebookId))
        print("=================個々田＝＝＝＝＝＝＝＝＝＝＝＝＝")
        if appDelegate.facebookId! == "<null>" {
            print(type(of: appDelegate.facebookId))  //Optional<String>
            print("＝＝＝＝＝＝＝＝＝＝＝＝＝＝相手はNilだよ＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
            let storyboard: UIStoryboard = UIStoryboard(name: "NoUserImage", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
            
        }else{
            
            print("============相手がいるよ==============")
            ref = Database.database().reference()
            ref.child("Users").child(self.appDelegate.facebookId!).observe(.value, with: { (snapshot) in
                print("facebookId\(self.appDelegate.facebookId!)")
                let items = snapshot.value as! [String: Any]
                    // マッチングした時間を取得
                    self.matchTime = items["time"]! as? String
                    print("==========確認==========\(items["time"]! as? String)============確認==========")
                    print("==========確認２==========\(self.matchTime!)============確認２==========")
    
                    // 現在時刻を取得して
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss"
                    // マッチングした時間を日付形式へ変換
                    let matchTime = formatter.date(from:  self.matchTime!)
                    print("==========matchTime==========\(matchTime!)============matchTime==========")
                    // マッチングした時間を自分のDBへ保存
                    self.ref.child("Users").child((self.user?.uid)!).updateChildValues(["time": self.matchTime])
                    // 現在時刻を取得して、
                    let displayTime = formatter.string(from: Date())
                    print("==========displayTime==========\(displayTime)============displayTime==========")
                    // 現在時刻を日付形式へ変換
                    let matched = formatter.date(from: displayTime)
                    print("==========matched==========\(matched!)============matched==========")
                    // 現在時刻からマッチングした時間を引いて何分経過しているか計算
                    let diff = Int(matched!.timeIntervalSince(matchTime!))
                    let myAbsoluteInt = 300 - diff
                    if(diff > 300 || diff <= 0){
                        self.userTimer = 0
                    }else{
                        self.userTimer = myAbsoluteInt
                }
                    print("==========diff==========\(diff)============diff==========")
                    print("======self.userTimer======\(self.userTimer)=======self.userTimer=======")
                forwardToMatch()
            })
        }
        
        func forwardToMatch(){
            //マッチング相手がいるページに遷移
            let storyboard: UIStoryboard = UIStoryboard(name: "MatchUser", bundle: nil)
            //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
            let second = storyboard.instantiateViewController(withIdentifier: "MatchUser") as? MatchUserImageViewController
            second?.userTimer = self.userTimer
            print("======self.userTimer======\(self.userTimer)")
            self.show(second!,sender: nil)
        }
        
       
        
        
    }
}
