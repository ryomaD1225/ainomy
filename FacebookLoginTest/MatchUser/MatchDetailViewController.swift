//
//  MatchDetailViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2019/02/22.
//  Copyright © 2019 kishirinichiro. All rights reserved.
//

import UIKit
import FirebaseStorage

class MatchDetailViewController: UIViewController {

    let navBar = UINavigationBar()
    let whiteView = UIView()
    let button = UIButton()
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var scale:CGFloat = 1.0
    var width:CGFloat = 0
    var height:CGFloat = 0
    var imageView = UIImageView()
    var image1:UIImage!
    var TestView = UIView()
    var nameLabel = UILabel()
    var ageLabel = UILabel()
    var userWorkPlace = UILabel()
    var line = CAShapeLayer()
    var selfIntroduction = UILabel()
    // ユーザがviewを開いた時の時間
    var arrivalTime:String!
    var timeValue:Double!
    var testTime:Int!
    
    var startTime:Date!
    override func loadView() {
        super.loadView()
        
        whiteView.backgroundColor = .white
        view.addSubview(whiteView)
        navigationBar()
        loadImage()
        showingUserInfo()
        matchingName()
        matchingAge()
        matchingJob()
        makingLine()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // 現在時刻を取得して
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
//         viewに遷移した時間を日付形式へ変換
        arrivalTime = formatter.string(from: Date())
        print("testTime：\(testTime)")
    }
    
    func navigationBar(){
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 64))
        let bgColor = UIColor.white
        TestView.alpha = 0.7
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
    }
    
    
    func loadImage(){
        image1 = UIImage(named:"userimage")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        imageView.image = image1
        // 画面の横幅を取得
        let screenWidth:CGFloat = self.view.frame.size.width
        let screenHeight:CGFloat = self.view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        // 元の真四角のやつ
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale, height:height*scale)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;
        imageView.clipsToBounds = true
        
        let storageref = Storage.storage().reference(forURL: "gs://facebooklogintest-3501b.appspot.com").child("images/\(String(describing: self.appDelegate.facebookId!)).jpg")
        print(storageref)
        //画像をセット
        imageView.sd_setImage(with: storageref)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.hero.id = "UserImage"
        // UIImageViewのインスタンスをビューに追加
        self.whiteView.addSubview(imageView)
        print("==============ここまで走っているよ①================")
        imageView.heightAnchor.constraint(equalToConstant: screenHeight/2).isActive = true
        imageView.topAnchor.constraint(equalTo: TestView.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
  
    }
    
    func matchingName(){
        
        nameLabel = UILabel()
        nameLabel.backgroundColor = .red
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = appDelegate.matchingUserName
        nameLabel.font = UIFont.systemFont(ofSize: 30)
        nameLabel.textAlignment = .center
        // 画像の中心を画面の中心に設定
        nameLabel.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        nameLabel.hero.id = "name"
        self.view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20.0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.0).isActive = true
        
    }
    
    func matchingAge(){
        print("==========うりゃ===============")
        ageLabel = UILabel()
        ageLabel.backgroundColor = .green
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.text = "\(appDelegate.matchingUserAge!)"
        ageLabel.font = UIFont.systemFont(ofSize: 30)
        ageLabel.textAlignment = .center
        // 画像の中心を画面の中心に設定
        ageLabel.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        ageLabel.hero.id = "age"
        self.view.addSubview(ageLabel)
        
        ageLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 20.0).isActive = true
        ageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.0).isActive = true
        print("==============ここまで走っているよ④================")
    }
    
    func matchingJob(){
        userWorkPlace = UILabel()
        userWorkPlace.backgroundColor = .green
        userWorkPlace.translatesAutoresizingMaskIntoConstraints = false
        userWorkPlace.text = appDelegate.matchingUserJob
        userWorkPlace.font = UIFont.systemFont(ofSize: 20)
        userWorkPlace.textAlignment = .center
        // 画像の中心を画面の中心に設定
        userWorkPlace.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        userWorkPlace.hero.id = "job"
        self.view.addSubview(userWorkPlace)
        
        userWorkPlace.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 20.0).isActive = true
        userWorkPlace.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20.0).isActive = true
    }
    
    // https://qiita.com/weed/items/1ae3f8304cbc28d8f38c
    func makingLine(){
        line = CAShapeLayer()
        // https://yuu.1000quu.com/how_to_specify_a_color_in_the_swift
        line.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2).cgColor
        line.lineWidth = 0.5
        
        
        let horizonalLine = UIBezierPath()
        horizonalLine.move(to: CGPoint(x:self.view.frame.origin.x, y:userWorkPlace.frame.origin.y + 180)) //始点
        horizonalLine.addLine(to:CGPoint(x:self.view.frame.width, y:userWorkPlace.frame.origin.y + 180))   //終点
        horizonalLine.close()  //線を結ぶ
        
        line.path = horizonalLine.cgPath
        self.view.layer.addSublayer(line)
        
    }
    
    
    
    func nextButton(){
    
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
        button.layer.cornerRadius = 50
        
        // ボタンのタイトルを設定
        button.setTitle("マッチ", for:UIControlState.normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalTo: ageLabel.widthAnchor, multiplier: 1.5).isActive = true
        button.heightAnchor.constraint(equalTo: ageLabel.heightAnchor, multiplier: 1.5).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
//        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        // ここで取得できているのは現在時刻
        let displayTime = formatter.string(from: Date())
        // この画面から離れる時間
        let leavingTime = formatter.date(from: displayTime)
        // この画面に遷移した時間
        let comingTime = formatter.date(from: arrivalTime)
        
        let diff = Int(leavingTime!.timeIntervalSince(comingTime!))
        print("diff：\(diff)")
        print("testTime：\(String(describing: testTime))")
        let totalTime = testTime - diff
        print("totalTime：\(totalTime)")
        let ansInt = totalTime
        print("ansInt：\(ansInt)")
        
//        if(diff <= 4){ timeValue = 4.9 }
//        if(diff <= 8 && diff > 4){ timeValue = 4.8 }
//        if(diff <= 12 && diff > 8){ timeValue = 4.7 }
//        if(diff <= 16 && diff > 12){ timeValue = 4.6 }
//        if(diff <= 20 && diff > 16){ timeValue = 4.5 }
//        if(diff <= 24 && diff > 20){ timeValue = 4.4 }
//        if(diff <= 28 && diff > 24){ timeValue = 4.3 }
//        if(diff <= 32 && diff > 28){ timeValue = 4.2 }
//        if(diff <= 36 && diff > 32){ timeValue = 4.1 }
//        if(diff <= 40 && diff > 36){ timeValue = 4 }
//        if(diff <= 48 && diff > 44){ timeValue = 3.9 }
//        if(diff <= 56 && diff > 52){ timeValue = 3.8 }
//        if(diff <= 66 && diff > 60){ timeValue = 3.7 }
//        if(diff <= 74 && diff > 70){ timeValue = 3.6 }
//        if(diff <= 82 && diff > 78){ timeValue = 3.5 }
//        if(diff <= 86 && diff > 82){ timeValue = 3.4 }
//        if(diff <= 94 && diff > 90){ timeValue = 3.3 }
//        if(diff <= 98 && diff > 94){ timeValue = 3.2 }
//        if(diff <= 102 && diff > 98){ timeValue = 3.1 }
//        if(diff <= 106 && diff > 102){ timeValue = 3 }
//        if(diff <= 110 && diff > 106){ timeValue = 2.9 }
//        if(diff <= 114 && diff > 110){ timeValue = 2.8 }
//        if(diff <= 118 && diff > 114){ timeValue = 2.7 }
//        if(diff <= 122 && diff > 118){ timeValue = 2.6 }
//        if(diff <= 126 && diff > 122){ timeValue = 2.5 }
//        if(diff <= 130 && diff > 126){ timeValue = 2.4 }
//        if(diff <= 134 && diff > 130){ timeValue = 2.3 }
//        if(diff <= 138 && diff > 134){ timeValue = 2.2 }
//        if(diff <= 142 && diff > 138){ timeValue = 2.1 }
//        if(diff <= 146 && diff > 142){ timeValue = 2 }
//        if(diff <= 150 && diff > 146){ timeValue = 1.9 }
//        if(diff <= 154 && diff > 150){ timeValue = 1.8 }
//        if(diff <= 158 && diff > 154){ timeValue = 1.7 }
//        if(diff <= 162 && diff > 158){ timeValue = 1.6 }
//        if(diff <= 168 && diff > 162){ timeValue = 1.5 }
//        if(diff <= 172 && diff > 168){ timeValue = 1.4 }
//        if(diff <= 176 && diff > 172){ timeValue = 1.3 }
//        if(diff <= 180 && diff > 176){ timeValue = 1.2 }
//        if(diff <= 184 && diff > 180){ timeValue = 1.1 }
//        if(diff <= 188 && diff > 184){ timeValue = 1 }
//        if(diff <= 192 && diff > 188){ timeValue = 0.9 }
//        if(diff <= 196 && diff > 192){ timeValue = 0.8 }
//        if(diff <= 200 && diff > 196){ timeValue = 0.7 }
//        if(diff <= 204 && diff > 200){ timeValue = 0.6 }
//        if(diff <= 208 && diff > 204){ timeValue = 0.5 }
//        if(diff <= 212 && diff > 208){ timeValue = 0.4 }
//        if(diff <= 216 && diff > 212){ timeValue = 0.3 }
//        if(diff <= 220 && diff > 216){ timeValue = 0.2 }
//        if(diff <= 224 && diff > 220){ timeValue = 0.1 }
//        if(diff > 224){ timeValue = 0 }

        let matchUser = MatchUserImageViewController()
        matchUser.hero.isEnabled = true
//        matchUser.userTimer = Int(timeValue)
        matchUser.userTimer = Int(ansInt)
        present(matchUser, animated: true, completion: nil)
      
    }
    
    func showingUserInfo(){
        selfIntroduction = UILabel()
        selfIntroduction.translatesAutoresizingMaskIntoConstraints = false
        selfIntroduction.text = appDelegate.userIntroducing
        selfIntroduction.font = UIFont.systemFont(ofSize: 23)
        selfIntroduction.textAlignment = .left
        // https://qiita.com/k_teluki/items/f86d1d4ff91cea2ca09e
        selfIntroduction.numberOfLines = 0
        selfIntroduction.frame.origin.y = self.view.frame.size.height*0.22
        selfIntroduction.backgroundColor = UIColor.blue
        
        self.view.addSubview(selfIntroduction)
        selfIntroduction.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 1).isActive = true
        selfIntroduction.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -4).isActive = true
        selfIntroduction.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -7.0).isActive = true
        selfIntroduction.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.42).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nextButton()
    }
    

}
