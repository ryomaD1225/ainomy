//
//  ViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/05.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//


import UIKit
//import Firebase
import FBSDKCoreKit
import FacebookCore
import FBSDKLoginKit
import FacebookLogin
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase
import CallKit


class ViewController: UIViewController, UIScrollViewDelegate , LoginButtonDelegate, CXProviderDelegate {
    // でんわ番号でloginする用ボタンのインスタンス生成
    var smsButton = UIButton()
    // facebook loginボタン用のインスタンスを生成
    var myLoginButton = UIButton(type: .custom)
    //アプリにFacebook公式のログインボタンを実装
    var loginButton = FBSDKLoginButton()
    var ref:DatabaseReference!
    var compared:String!
    let userDefaults = UserDefaults.standard
    var token:String!
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // ユーザの性別を代入する変数
    var userStatus:String!
    // アプリをクリアした時間を代入する変数
    var clearTime:String!
    // ユーザーとマッチした時間を代入する変数
    var matchedTime:String!
    // アプリをクリアした時の時間とマッチした時間差を保持するための変数
    var timeLag:Int!
    
    public func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("=====logout=====")
    }

    private var pageControll: UIPageControl!
    private var scrollView: UIScrollView!
    
    override func loadView() {
        super.loadView()
    
        // Do any additional setup after loading the view.
        // アプリ起動時・フォアグラウンド復帰時の通知を設定する
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SelectNumberViewController.onDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
     
    }
    
    func saveLoginStatus(str: String){
        userDefaults.set(str, forKey: "UserStatus")
    }
    
    // アプリ起動時・フォアグラウンド復帰時に行う処理
    @objc func onDidBecomeActive(_ notification: Notification?) {
// ユーザのログイン情報によって最初に遷移する画面を切り替えている。
            //UserDefaultsがの中身がnilじゃない場合の処理
            if UserDefaults.standard.object(forKey: "UserStatus") != nil{
                userStatus = userDefaults.object(forKey: "UserStatus") as? String
                if userStatus == "LoggedOut" {
                     print("===================logoutしていればここが走るよ========================")
                }else {
                    // ユーザがログインしているでステータスが確認できれば人数セレクト画面へ遷移する
                    let storyboard: UIStoryboard = UIStoryboard(name: "SelectNumber", bundle: nil)
                    let UserInfo = storyboard.instantiateInitialViewController()
                    self.present(UserInfo!, animated: true, completion: nil)
                    print("===================nilじゃなければページ移動========================")
                }
            }else{
            }
    }
   
    func saveDeviceToken(str: String){
        UserDefaults.standard.set(token, forKey: "DEVICE_TOKEN")
    }
    // マッチング済み、且つ制限時間がまだ残っている場合のみ処理が走る
    func forwardToMatch(){
        // マッチングユーザuidを変数へ代入
        appDelegate.facebookId = userDefaults.object(forKey: "UserStatus") as? String
        //マッチング相手がいるページに遷移
        let storyboard: UIStoryboard = UIStoryboard(name: "MatchUser", bundle: nil)
        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
        let second = storyboard.instantiateViewController(withIdentifier: "MatchUser") as? MatchUserImageViewController
        second?.userTimer = timeLag
        print("======timeLag：\(String(describing: timeLag))")
        self.show(second!,sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                                facebookAuth()
                                smsAuthentication()
    }
    
    func facebookAuth(){
        // Viewのサイズ
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        self.myLoginButton.backgroundColor = UIColor.darkGray
        self.myLoginButton.frame = CGRect(x: CGFloat(3) * width + width / 2 - 120, y: height*0.75, width: width*0.75, height: height*0.10)
        self.myLoginButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height*0.75)
        self.myLoginButton.setTitle("Facebookではじめる", for: .normal)
        self.myLoginButton.backgroundColor = UIColor.blue
        // 以下2行が丸くする処理
        self.myLoginButton.layer.cornerRadius = 50.0 //どれくらい丸くするのか
        
        // Handle clicks on the button
        self.myLoginButton.addTarget(self, action: #selector(ViewController.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        self.view.addSubview(self.myLoginButton)
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email, .userGender], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("Facebook Login Cancelled")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Facebook Login Success")
                self.loginFireBase()
                break
            }
        }
    }
    
    func smsAuthentication(){
        // サイズを変更する
        smsButton.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        // 任意の場所に設置する
        smsButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
        
        // 文字色を変える
        smsButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        // 背景色を変える
        smsButton.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.6, alpha: 1)
        
        // 枠の太さを変える
        smsButton.layer.borderWidth = 1.0
        
        // 枠の色を変える
        smsButton.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        smsButton.layer.cornerRadius = 25
        
        // ボタンのタイトルを設定
        smsButton.setTitle("電話番号でログインする", for:UIControlState.normal)
        smsButton.translatesAutoresizingMaskIntoConstraints = false
       
        // タップされたときのaction
        smsButton.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(smsButton)
         smsButton.topAnchor.constraint(equalTo: myLoginButton.bottomAnchor, constant: 30.0).isActive = true
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        
    }
    
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    
    

    
    
    func scrollViewDidEndDecelerating (_ scrollView: UIScrollView) {
        // スクロール距離 = 1ページ(画面幅)
        if fmod(scrollView.contentOffset.x, scrollView.frame.width) == 0 {
            // ページの切り替え
            pageControll.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
    
    
   
    
    
    //Called when the button was used to login and the process finished.
    //デリゲートで didCompleteWithResult:error: を実装します。
    public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
    
        let loginManager = LoginManager()
        
        switch result {
        case .failed(let error):
            print("Error \(error)")
            break
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("loginFireBase成功！")
            loginFireBase()
            break
        default: break
            
        }
        
    }
    

    //viewDidAppear：画面が表示された直後。http://blog.livedoor.jp/sasata299/archives/52029262.html
        override func viewDidAppear(_ animated: Bool) {
                print("User not Logged In")
                ref = Database.database().reference()
        }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    //ここの関数内のuserDefaults.setで保存している。
    func saveName(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "saveName")
    }
    
    
    /**
     Login to Firebase after FB Login is successful
     */
    func loginFireBase() {
        
        //ユーザがログインに成功したらログインしたユーザのアクセストークンを取得してFirebase認証情報と交換します。
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        print("=============================================")
        print("FBSDKAccessToken.current,\(FBSDKAccessToken.current())")
        
        //待機中のくるくるしてるやつ。
        SVProgressHUD.show()
        
        //最後に、Firebase 認証情報を使用して Firebase での認証を行います。
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil {
                print("===エラ==============================")
                print(error)
                // ここでエラーが発生
                return
            }else if FBSDKAccessToken.current() != nil{
                
                SVProgressHUD.dismiss()
                let storyboard: UIStoryboard = UIStoryboard(name: "UserGender", bundle: nil)
                let nextView = storyboard.instantiateInitialViewController()
                self.present(nextView!, animated: true, completion: nil)
                self.postUser()
                
                
            }
        }
    }
    
    
    
    func postUser(){
        guard let user = Auth.auth().currentUser else{
            assert(true, "post user with nil")
            return
        }
        
        let facebookId = FBSDKAccessToken.current().userID
        let userRef = ref.child("Users")
        
        userRef
            .queryOrdered(byChild: "facebookId")
            .queryEqual(toValue: facebookId)
            .observeSingleEvent(of: DataEventType.value) { (snapshot) in
                if snapshot.exists() {
                    print("Exist user")
                    let name = user.displayName!.split(separator: " ")
                    let first = (String(name[0]))
                    print(first)
                    self.saveName(str: first)
                }else{
                    let name = user.displayName!.split(separator: " ")
                    let first = name[0]
                    print(first)
                    self.saveName(str: user.displayName!)
                    // AppDelegate.swiftファイルでuserDefaultsに登録したdevicetokenをfirebaseへ保存
                    self.token = self.userDefaults.object(forKey: "DEVICE_TOKEN") as? String
                    
                    // FBSDKAccessTokenにはuserIDが含まれています。これを使用して利用者を特定できます。
                    let postUser = ["facebookId": FBSDKAccessToken.current().userID,
                                    "name": user.displayName,
                                    "deviceToken": self.token]
                    let postUserRef = userRef.child(user.uid)
                    postUserRef.updateChildValues(postUser)
                }
        }
    }
    
    // 今後使う予定
    func pagenation(){
            // ページ数
            let page = 4
            
            // Viewのサイズ
            let width = self.view.frame.width
            let height = self.view.frame.height
            
            // UIScrollViewの設定
            scrollView = UIScrollView()
            scrollView.frame = self.view.frame
            scrollView.isPagingEnabled = true
            scrollView.delegate = self
            scrollView.showsHorizontalScrollIndicator = false
            
            //scrollViewのサイズ
            scrollView.contentSize = CGSize(width: CGFloat(page) * width, height: 0)
            
            self.view.addSubview(scrollView)
            
            
            // pageごとのラベルを作成
            for i in 0 ..< page - 1 {
                let label: UILabel = UILabel()
                label.frame = CGRect(x: CGFloat(i) * width + width / 2 - 60, y: height / 2 - 40, width: 120, height: 80)
                label.textAlignment = NSTextAlignment.center
                label.text = "\(i+1)つ目のページ"
                scrollView.addSubview(label)
            }
            
            // 4ページ目にfacebookログインボタンの表示
            let loginButton = LoginButton(readPermissions: [ .email, .publicProfile, .userGender ])
            loginButton.frame = CGRect(x: CGFloat(3) * width + width / 2 - 120, y: height / 2 + 100, width: 240, height: 50)
            loginButton.delegate = self
            scrollView.addSubview(loginButton)
            
            // UIPageControllの設定
            pageControll = UIPageControl()
            pageControll.frame = CGRect(x: 0, y: height - 50, width: width, height: 50)
            pageControll.pageIndicatorTintColor = UIColor.lightGray
            pageControll.currentPageIndicatorTintColor = UIColor.blue
            pageControll.numberOfPages = page
            pageControll.currentPage = 0
            
            self.view.addSubview(pageControll)
        
    }
}

