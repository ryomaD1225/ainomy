//
//  NoUserImageViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/07.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit
import SkyWay
import Firebase
import FirebaseDatabase



class NoUserImageViewController: UIViewController {
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    fileprivate var peer: SKWPeer?
    var peerId:String!
    var imageView: UIImageView!
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    // ボタンのインスタンス生成
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("相手がいないよ＝＝＝＝＝＝＝＝＝")
        ref = Database.database().reference()
        
        // 元のバックのビューは、とりあえず透明にして見えなくする
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        // UIVisualEffectViewを生成する
        let visualEffectView = UIVisualEffectView(frame: view.frame)
        // エフェクトの種類を設定
        visualEffectView.effect = UIBlurEffect(style: .regular)
        // UIVisualEffectViewを他のビューの下に挿入する
        view.insertSubview(visualEffectView, at: 0)
        
        
        backSugest()
        backButton()

    }
    
    private func backSugest(){
        
        let image1:UIImage = UIImage(named:"sorry")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        // UIImageView 初期化
        imageView = UIImageView(image:image1)
        imageView.isUserInteractionEnabled = true;
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale, height:height*scale)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)

        
    }
    
    func backButton(){
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
        button.setTitle("戻る", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.imageView.addSubview(button)
        
    }
    
    @objc func buttonTapped(sender: UIButton) {
        print("押してるよ")
        let storyboard: UIStoryboard = UIStoryboard(name: "NoneUser", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        self.present(UserInfo!, animated: true, completion: nil)
    }
}
