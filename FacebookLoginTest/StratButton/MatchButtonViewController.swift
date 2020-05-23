//
//  MatchButtonViewController.swift
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
import Lottie

class MatchButtonViewController: UIViewController {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    // ボタンのインスタンス生成
    let button = UIButton()
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton()
        showAnimation()
        // Do any additional setup after loading the view.
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
        animationView.animationSpeed = 2
        view.addSubview(animationView)
        animationView.play()
    }

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
        button.setTitle("マッチスタート", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
        
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        
            //存在しなければ、自分のテーブルに値をストア
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let displayTime = formatter.string(from: Date())
        
            ref = Database.database().reference()
            self.ref.child("Users").child((self.user?.uid)!).updateChildValues(["time": displayTime])
           // キャッシュクリア時にすぐ元の画面に遷移して戻ってこれるようにマッチした時間を保持しておく
            self.saveMatchingTime(str: displayTime)
        //マッチング相手がいるページに遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "MatchUser", bundle: nil)
        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
        let second = storyboard.instantiateViewController(withIdentifier: "MatchUser") as? MatchUserImageViewController
//        second?.userTimer = Int(displayTime) ?? 5
        second?.userTimer = Int(300)
        self.show(second!,sender: nil)
    }
    
    func saveMatchingTime(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "matchedTime")
    }

}
