//
//  GenderViewController.swift
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

class GenderViewController: UIViewController {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    let userDefaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var UserImage:UILabel!
    //ページコントロールのための変数を定義
    var pageControl = UIPageControl(frame: .zero)
    // ボタンのインスタンス生成
    let button = UIButton()
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    
    var maleImageView: UIImageView!
    var femaleImageView: UIImageView!
    
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setTest(str: "性別を教えてください")
        setupPageControl()
        maleImage()
        femaleImage()
        navigationBar()
        backButton()
   

        // Do any additional setup after loading the view.
    }
    
    private func maleImage(){
        
        let image1:UIImage = UIImage(named:"maleimage")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        maleImageView = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        maleImageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        maleImageView.center = CGPoint(x:screenWidth/4, y:screenHeight/2)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(maleImageTapped(tapGestureRecognizer:)))
        maleImageView.isUserInteractionEnabled = true
        maleImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(maleImageView)
 
    }
    
    private func femaleImage(){
        
        let image1:UIImage = UIImage(named:"femaleimage")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        femaleImageView = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/2, height:height*scale/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        femaleImageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        femaleImageView.center = CGPoint(x:screenWidth/4*3, y:screenHeight/2)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(femaleImageTapped(tapGestureRecognizer:)))
        femaleImageView.isUserInteractionEnabled = true
        femaleImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(femaleImageView)
        
    }
    
    func navigationBar(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        let TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 64))
        let bgColor = UIColor.white
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
        
        let label = UILabel();
        label.text = "プロフィール登録";
        label.center = self.view.center
        label.sizeToFit();
        label.layer.position = CGPoint(x: self.view.frame.width/2, y:view.frame.origin.y + 40)
        
        self.view.addSubview(label);
    }
    
    
    // ジェスチャーイベント処理
    @objc func maleImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        // 設定済みをマーク.
        self.appDelegate.genderText = "male"
        saveData(str: appDelegate.genderText)
        ref.child("Users").child((user?.uid)!).updateChildValues(["gender": appDelegate.genderText!])
        print("男性選択")
        nextPage()
    
    }
    
    // ジェスチャーイベント処理
    @objc func femaleImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        // 設定済みをマーク.
        self.appDelegate.genderText = "female"
        saveData(str: appDelegate.genderText)
        print(appDelegate.genderText)
        ref.child("Users").child((user?.uid)!).updateChildValues(["gender": appDelegate.genderText!])
        print("女性選択")
        nextPage()
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveData(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "saveGender")
        
    }
  
    
    func setTest(str: String) {
        UserImage = UILabel()
        UserImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        UserImage.text = str
        UserImage.sizeToFit()
        UserImage.center = self.view.center
        UserImage.frame.origin.y = UserImage.frame.origin.y - 200
        
        self.view.addSubview(UserImage)
        
    }
    
    func setupPageControl() {
        
        
        let label2 = UILabel(frame: CGRect(x: self.view.frame.width/2, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label2.text = " STEP2";
        label2.sizeToFit();
        label2.layer.position = CGPoint(x: self.view.frame.width/2, y:UserImage.frame.origin.y - 50)
        
        label2.textColor = UIColor.lightGray
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
    
    func backButton(){
        
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "プロフィール登録")
        
        //ナビゲーションバーにアイテムを追加
        navBar.pushItem(navItem, animated: true)
        // Viewにボタンを追加
        self.view.addSubview(navBar)
    }
    
    
    func nextPage(){
        print("appDelegate.genderTextを確認＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
        print(appDelegate.genderText!)
        let storyboard: UIStoryboard = UIStoryboard(name: "UserInfo", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }
    
  


}
