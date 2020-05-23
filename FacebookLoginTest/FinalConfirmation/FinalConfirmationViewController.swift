//
//  FinalConfirmationViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2019/01/30.
//  Copyright © 2019 kishirinichiro. All rights reserved.
//

import UIKit

class FinalConfirmationViewController: UIViewController {

    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    var UserImage:UILabel!
    // ユーザ画像周り宣言
    var imageView: UIImageView!
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale:CGFloat = 1.0
    
    let button = UIButton()
    let sampleUILabel:UILabel = UILabel()
    //①ディレクトリのURLを指定
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let DocumentDirectoryFileURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    // ドキュメントディレクトリの「パス」（String型）
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        backButton()
        setTest()
        drowning()
        initImageView()
        nameLabel()
        ageLabel()
        educationLabel()
        nextPage()
        selectedGender()
    }
    
    func backButton(){
        let screenWidth:CGFloat = view.frame.size.width
        let TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 64))
        let bgColor = UIColor.white
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
        
        let items = UIBarButtonItem(barButtonHiddenItem: .Back, target: nil, action: #selector(self.myAction))
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "プロフィール確認")
        
        //ナビゲーションバーの左ボタンを追加
        navItem.leftBarButtonItem = items
        
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
    
    func setTest() {
        UserImage = UILabel()
        UserImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        UserImage.text = """
        相飲み相手にはこのように
        表示されます
        """
        UserImage.textAlignment = NSTextAlignment.center
        UserImage.numberOfLines = 2
        UserImage.sizeToFit()
        UserImage.center = self.view.center
        UserImage.frame.origin.y = navBar.bounds.height + 50
        self.view.addSubview(UserImage)
        
    }
    
    func drowning(){
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        let TestView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth * 0.75, height: screenHeight/2))
        TestView.center = CGPoint(x:screenWidth/2, y:screenHeight/2 - 20)
        let bgColor = UIColor.blue
        TestView.backgroundColor = bgColor
        self.view.addSubview(TestView)
        
        //右上と左下を角丸にする設定
        TestView.layer.cornerRadius = 10
        TestView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
        // 元の真四角のやつ
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale-200, height:height*scale-200)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        //        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2 )
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2 - 50 )
        // 角丸にする
        //        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        
        print("-------------------")
        print(String(describing: UserDefaults.standard.url(forKey: "userImage")))
        print("-------------------")
        
        //上で存在を確認した画像をから「profileImageView」というイメージビューに値を代入する
        if UserDefaults.standard.url(forKey: "userImage") == nil {
            userDefaults.set(documentDirectoryFileURL, forKey: "userImage")
        }
        
        //（String型のfileWithPathのメソッドがSwiftにないので、一度URL型に変更）
        let fileURL = URL(fileURLWithPath: filePath).appendingPathComponent("localData.png")
        
        // UserDefaultsの情報を参照してpath指定に使う
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
    
    func nameLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        //        let screenHeight:CGFloat = view.frame.size.height
        let label = UILabel()
        label.frame = CGRect(x:150, y:200, width:160, height:30)
        label.text = readName()
        label.font = UIFont.systemFont(ofSize: 23)
        label.textAlignment = .center
        // 画像の中心を画面の中心に設定
        label.center = CGPoint(x:screenWidth/2, y:imageView.frame.height + 230)
        self.view.addSubview(label)
        
    }
    
    func readName() -> String {
        
        let str: String = userDefaults.object(forKey: "saveName") as! String
        
        return str
    }
    
    func ageLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width

        let label = UILabel()
        label.frame = CGRect(x:150, y:200, width:160, height:30)
        label.text = readAge() + "歳"
        label.textAlignment = .center
        // 画像の中心を画面の中心に設定
        label.center = CGPoint(x:screenWidth/2, y:imageView.frame.origin.y + 260)
        self.view.addSubview(label)
    }
    
    func readAge() -> String {
        
        let str: String = userDefaults.object(forKey: "inputAge") as! String
        
        return str
    }
    
    func educationLabel(){
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        //        let screenHeight:CGFloat = view.frame.size.height
        let label = UILabel()
        label.frame = CGRect(x:150, y:200, width:160, height:30)
        label.text = readJob()
        label.textAlignment = .center
        // 画像の中心を画面の中心に設定
        label.center = CGPoint(x:screenWidth/2, y:imageView.frame.origin.y + 285)
        self.view.addSubview(label)
    }
    
    //この関数がviewdidload時に読み込まれて保存したデータの読み込み作業をしている。
    func readJob() -> String {
        
        let str: String = userDefaults.object(forKey: "inputJob") as! String
        
        return str
    }
    
    func nextPage(){
        
        // サイズを変更する
        button.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 50, height: 50)
        
        // 任意の場所に設置する
        button.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height - 130)
        
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
        button.setTitle("プロフィールを決定", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
    }
    
    @objc func buttonTapped(sender : AnyObject) {
       
            let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
      
    }
    
    func selectedGender(){
        print("===================selectedGenderLabel===================")
    
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
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
        // 画面に追加
        self.view.addSubview(sampleUILabel)
        
        
        
        
    }
    
    
    @objc private func textDidBeginEditing(tapGestureRecognizer: UITapGestureRecognizer){
        print("you tatched")// handle begin editing event
        self.dismiss(animated: true, completion: nil)
    }
    
   

}
