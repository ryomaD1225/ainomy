//
//  CustomPresentationController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/11/18.
//  Copyright © 2018 kishirinichiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CustomPresentationController: UIPresentationController {

    // 呼び出し元のView Controller の上に重ねるオーバレイView
    var overlayView = UIView()
    var backHomeButton = UIButton()
    var cancellingButton = UIButton()
    
    //firebase保存のためインスタンスを定義
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    
    //UserDefaultsのために
    let userDefaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 帰宅した時にマッチング相手をアクティブにするための変数を定義
    var coming:String!
    var waiting:String!
    
    //ユーザの性別が入る変数
    var genderInfo:String!
    
    // ユーザが人数を選択した場合に選択した人数を保持する変数
    var numberPeople:String!
    
    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        
        ref = Database.database().reference()
        
        guard let containerView = containerView else {
            return
        }
        //overlayViewは薄暗く靄がかったところ
        overlayView.frame = containerView.bounds
        overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.overlayViewDidTouch(_:)))]
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)
        
        // トランジションを実行
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.7
            }, completion:nil)
    }
    
    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion:nil)
    }
    
    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }
    
    let margin = (x: CGFloat(30), y: CGFloat(220.0))
    
    // 子のコンテナサイズを返す
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - margin.x, height: parentSize.height - margin.y)
    }
    
    // 呼び出し先のView Controllerのframeを返す
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect()
        let containerBounds = containerView!.bounds
        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = childContentSize
        presentedViewFrame.origin.x = margin.x / 2.0
        presentedViewFrame.origin.y = margin.y / 2.0
        
        return presentedViewFrame
    }
    
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        presentedView?.backgroundColor = .white
        overlayView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 10
        presentedView?.clipsToBounds = true
    }
    
    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
        backButton()
        cancellButton()
        readGender()
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readGender() -> String {
        //UserDefaultsがの中身がnilじゃない場合の処理
        if UserDefaults.standard.object(forKey: "saveGender") != nil{
            genderInfo = userDefaults.object(forKey: "saveGender") as? String
            print(genderInfo)
            print("===================UserDafault性別========================")
        }
        return genderInfo
    }
    
    // overlayViewをタップした時に呼ばれる
    @objc func overlayViewDidTouch(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    func backButton(){
        // サイズを変更する
        backHomeButton.frame = CGRect(x: 0, y: 0, width: containerView!.bounds.width-50, height: 50)
        
        // 任意の場所に設置する
        backHomeButton.layer.position = CGPoint(x: overlayView.frame.width/2-15, y:overlayView.frame.height/2+20)
        
        // 文字色を変える
        backHomeButton.setTitleColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), for: UIControlState.normal)
        
        // 背景色を変える
        backHomeButton.backgroundColor = .white
        
        // 枠の太さを変える
        backHomeButton.layer.borderWidth = 1.0
        
        // 枠の色を変える
        backHomeButton.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        backHomeButton.layer.cornerRadius = 10
        
        // ボタンのタイトルを設定
        backHomeButton.setTitle("帰宅する", for:UIControlState.normal)
        
        // タップされたときのaction
        backHomeButton.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.presentedView?.addSubview(backHomeButton)
        
    }
    
    @objc func buttonTapped(sender: UIButton) {
        print("押してるよ")
        let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        presentedViewController.present(UserInfo!, animated: true, completion: nil)
        markingUser()
     
    }
    
    func markingUser(){
        // データベースでユーザのステータスの状態が「帰宅」状態になる。
        self.ref.child("backHome").updateChildValues([(self.user?.uid)!: "false"])
        // 人数を選択している場合には以下の処理が走る。
        ref.child("selected").child((user?.uid)!).child("number").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
            self.numberPeople = snapshot.value as! String
            print("====-numberPeople====\(self.numberPeople)")
        // データベースから自分の情報を削除する
        self.ref.child("field").child(self.genderInfo).child(self.numberPeople).child((self.user?.uid)!).removeValue()
                
                self.matchingUserActive()
            }
   
            
        })

    }
    
    // 帰宅ボタンを押した際にマッチング相手のステータスをアクティブにする。
    func matchingUserActive(){
        // 以下処理でマッチング相手と自分のデータを取得する
        self.ref.child("match").child((self.user?.uid)!).child("coming").observe(.value, with: { (snapshot) in
            
            if snapshot.exists(){
                // 存在していればそそのままcoming変数へ代入
                self.coming = snapshot.value as? String
                print("存在しているよ\(self.coming)")
            }else{
                // 存在していなければ自分のidをcoming変数へ保存
                self.coming = self.user?.uid
                print("存在していないよ\(self.coming)")
            }
        // 以下処理でマッチング相手と自分のデータを取得する
        self.ref.child("match").child((self.user?.uid)!).child("waiting").observe(.value, with: { (snapshot) in
                
                if snapshot.exists(){
                    // 存在していればそそのままwaiting変数へ代入
                    self.waiting = snapshot.value as? String
                    print("存在しているよ\(self.waiting)")
                }else{
                    // 存在していなければ自分のidをwaiting変数へ保存
                    self.waiting = self.user?.uid
                    print("存在していないよ\(self.waiting)")
                }
               // 上記の確認後に以下関数を発火
                self.finalInspection()
            })
   
        })
    }
    
    func finalInspection(){
        
        print("ここは走っているか①\(coming,waiting)")
        // coming変数が自分のユーザidと違ければ(マッチング相手のidであれば)以下の処理が走る
        if coming != user?.uid {
            print("ここは走っているか②")
            // 自分の性別がmaleであればfemaleを
            if genderInfo == "male"{
                print("ここは走っているか(2.5)\(user?.uid)")
                // 以下の変数へ代入
               appDelegate.matchingGender = "female"
                ref.child("field").child(appDelegate.matchingGender).child(self.numberPeople).child(coming).observe(.value, with: { (snapshot) in
                    // マッチング相手がまだ帰宅していないかここで確認している。
                    if snapshot.exists(){
                        let data = ["true":self.coming]
                        // そしてマッチング相手のせステータスをアクティブにする
                         self.ref.child("field").child(self.appDelegate.matchingGender).child(self.numberPeople).child(self.coming).setValue(data)
                    }else{
                        print("アクティブにするマッチング相手はいないよ。")
                    }
                })
               
                
            }else{
                print("ここは走っているか⑤\(user?.uid)")
                // 性別がfemaleであればmaleを以下の変数へ代入して
                appDelegate.matchingGender = "male"
                
                ref.child("field").child(appDelegate.matchingGender).child(self.numberPeople).child(coming).observe(.value, with: { (snapshot) in
                    if snapshot.exists(){
                        //マッチング相手のステータスをアクティブにする
                        let data = ["true":self.coming]
                        self.ref.child("field").child(self.appDelegate.matchingGender).child(self.numberPeople).child(self.coming).setValue(data)
                    }else{
                        print("アクティブにするマッチング相手はいないよ。")
                    }
                })
             
            }
        // waiting変数が自分のユーザidと違ければ(マッチング相手のidであれば)以下の処理が走る
        }else if waiting != user?.uid {
            print("ここは走っているか③\(user?.uid)")
            // 性別がfemaleであれば
            if genderInfo == "female"{
                print("ここは走っているか④\(user?.uid)")
                // maleを以下の変数に代入して
               appDelegate.matchingGender = "male"
                ref.child("field").child(appDelegate.matchingGender).child(self.numberPeople).child(waiting).observe(.value, with: { (snapshot) in
                    // マッチング相手がまだ帰宅していないかここで確認している。
                    if snapshot.exists(){
                        // マッチング相手のステータスをアクティブにする
                        let data = ["true":self.waiting]
                        self.ref.child("field").child(self.appDelegate.matchingGender).child(self.numberPeople).child(self.waiting).setValue(data)
                    }else{
                        print("アクティブにするマッチング相手はいないよ。")
                    }
                })
                
                
            }else{
                 print("ここは走っているか⑥\(user?.uid)")
                // 性別がmaleであればfemaleを以下の変数に代入
                appDelegate.matchingGender = "female"
                ref.child("field").child(appDelegate.matchingGender).child(self.numberPeople).child(waiting).observe(.value, with: { (snapshot) in
                    // マッチング相手がまだ帰宅していないかここで確認している。
                    if snapshot.exists(){
                        // マッチング相手のステータスをアクティブにする
                        let data = ["true":self.waiting]
                        self.ref.child("field").child(self.appDelegate.matchingGender).child(self.numberPeople).child(self.waiting).setValue(data)
                    }else{
                        print("アクティブにするマッチング相手はいないよ。")
                    }
                })
            }
        }
    }
    
    func cancellButton(){
        // サイズを変更する
        cancellingButton.frame = CGRect(x: 0, y: 0, width: containerView!.bounds.width-50, height: 50)
        
        // 任意の場所に設置する
        cancellingButton.layer.position = CGPoint(x: overlayView.frame.width/2-15, y:overlayView.frame.height/2 + 80)
        
        // 文字色を変える
        cancellingButton.setTitleColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), for: UIControlState.normal)
        
        // 背景色を変える
        cancellingButton.backgroundColor = .white
        
        // 枠の太さを変える
        cancellingButton.layer.borderWidth = 1.0
        
        // 枠の色を変える
        cancellingButton.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        cancellingButton.layer.cornerRadius = 10
        
        // ボタンのタイトルを設定
        cancellingButton.setTitle("キャンセル", for:UIControlState.normal)
        
        // タップされたときのaction
        cancellingButton.addTarget(self,
                                 action: #selector(cancellTapped(sender:)),
                                 for: .touchUpInside)
        
        // Viewにボタンを追加
        self.presentedView?.addSubview(cancellingButton)
        
    }
    
    @objc func cancellTapped(sender: UIButton) {
        presentedViewController.dismiss(animated: true, completion: nil)
        
    }
}
