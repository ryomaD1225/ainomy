//
//  VoipAcceptUserViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2019/02/13.
//  Copyright © 2019 kishirinichiro. All rights reserved.
//

import UIKit
import AVFoundation
import CallKit
import SkyWay
import Firebase
import FirebaseStorage
import NVActivityIndicatorView
// Voip通知用
import OneSignal
import SkyWay

class VoipAcceptUserViewController: UIViewController {
    
    
    var ref: DatabaseReference!
    // ボタンのインスタンス生成
    let backButton = UIButton()
    // MatchUserImageViewからのpeerId情報を保持する為に定義
    var peerId:String!
    var imagePath:String!
    var scale:CGFloat = 1.0
    var width:CGFloat = 0
    var height:CGFloat = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageView = UIImageView()
    var image1:UIImage!
    var dissConnectCall: UIImageView!
    var label = UILabel()
    var timer:Timer!
    var timerMinute = UILabel()
    var timerSecond = UILabel()
    var startTime = Date()

    
    // (https://github.com/ninjaprox/NVActivityIndicatorView)
    private var activityIndicatorView: NVActivityIndicatorView!
    
    //skywayで利用するインスタンス(オブジェクト)変数の宣言
    fileprivate var peer: SKWPeer? //①//Peerオブジェクト
    fileprivate var mediaConnection: SKWMediaConnection?//②MediaConnectionオブジェクト
    fileprivate var localStream: SKWMediaStream? //自分自身のMediaStreamオブジェクト
    fileprivate var remoteStream: SKWMediaStream?//相手のMediaStreamオブジェクト
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        loadImage()
        phoneImage()
        matchingName()
//        startTimer()
        // setup()
        // 電話を切った後にconnectedを切る処理をする
    
        print("=============VoipAcceptUserViewController==========")
        ref.child("backHome").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.appDelegate.facebookId = snapshot.value as? String
            
        })
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
        let rect:CGRect = CGRect(x:0, y:0, width:screenWidth, height:screenHeight/2)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;
        // 画像の中心を画面の中心に設定
        
        imageView.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.origin.y)
        
        //        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true
        
        let storageref = Storage.storage().reference(forURL: "gs://facebooklogintest-3501b.appspot.com").child("images/\(String(describing: self.appDelegate.facebookId!)).jpg")
        print(storageref)
        //画像をセット
        imageView.sd_setImage(with: storageref)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        print("==============ここまで走っているよ①================")
        imageView.heightAnchor.constraint(equalToConstant: screenHeight/2).isActive = true
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
    }
    
    
    private func phoneImage(){
        
        let image1:UIImage = UIImage(named:"Image")!
        
        // 画像の幅・高さの取得
        width = image1.size.width
        height = image1.size.height
        
        // UIImageView 初期化
        dissConnectCall = UIImageView(image:image1)
        
        // 画面の横幅を取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        scale = screenWidth / width
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale/5, height:height*scale/5)
        
        //ImgaeView FrameをCGRectで作った矩形に合わせる
        dissConnectCall.frame = rect;
        
        dissConnectCall.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height * 0.80)
        
        // 画像の中心を画面の中心に設定
        dissConnectCall.center = CGPoint(x:screenWidth/2, y:screenHeight*0.85)
        
        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(disscallTapped(tapGestureRecognizer:)))
        dissConnectCall.isUserInteractionEnabled = true
        dissConnectCall.addGestureRecognizer(tapGestureRecognizer)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(dissConnectCall)
        
    }
    
    // 電話接続を切断して前の画面に戻る処理
    @objc func disscallTapped(tapGestureRecognizer: UITapGestureRecognizer){
        // 以下の処理でpeerを切断している
       appDelegate.myPeerId?.disconnect()
        print("押している")

    }
    
    func startTimer(){
        print("startTimer")
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.timerCounter),
            userInfo: nil,
            repeats: true)
        print("startTimer")
        startTime = Date()
    }
    
    
    @objc func timerCounter() {
        print("timerCounter")
        let currentTime = Date().timeIntervalSince(startTime)
        
        // fmod() 余りを計算
        let minute = (Int)(fmod((currentTime/60), 60))
        // currentTime/60 の余り
        let second = (Int)(fmod(currentTime, 60))
        
        // %02d： ２桁表示、0で埋める
        let sMinute = String(format:"%02d", minute)
        let sSecond = String(format:"%02d", second)
        
        timerMinute.text = sMinute
        timerSecond.text = sSecond
        
        timerSecond.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        timerMinute.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        timerMinute.center = CGPoint(x:self.view.frame.size.width/3, y:self.view.frame.size.height/2)
        timerSecond.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        print("timerCounter")
        self.view.addSubview(timerSecond)
        self.view.addSubview(timerMinute)
        
    }
    
    func matchingName(){
        
        label = UILabel()
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = appDelegate.matchingUserName
        label.font = UIFont.systemFont(ofSize: 23)
        label.textAlignment = .center
        // 画像の中心を画面の中心に設定
        label.center = CGPoint(x:self.view.frame.size.width/2, y:self.view.frame.size.height/2)
        
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30.0).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        timer.invalidate()
    }
    
}



extension VoipAcceptUserViewController{
        
        func setup(){
            print("================func setup()====================")
            // 以下でappdelegareファイルからskywayのAPI情報を取得してapikey変数に代入(http://sona.hateblo.jp/entry/2018/02/19/210000)
            guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
                print("Not set apikey or domain")
                return
            }
            
            // 以下の処理でskywayレンダリングサーバに通信して任意のpeeridを作成している
            let option: SKWPeerOption = SKWPeerOption.init();
            // apikey所持
            option.key = apikey
            // domain情報保持
            option.domain = domain
            
            // 自身のpeeridを取得する
            peer = SKWPeer(options: option)
            
            if let _peer = peer{
                self.setupPeerCallBacks(peer: _peer)
                self.setupStream(peer: _peer)
            }else{
                // peerid生成に失敗したらcallkitを表示させないようにここで処理を終わらせる！ + 発電側にも電話が繋がらない表示をさせる！
                print("failed to create peer setup")
            }
        }
        
        func setupStream(peer:SKWPeer){
            print("=================setupStream=================")
            SKWNavigator.initialize(peer);
            let constraints:SKWMediaConstraints = SKWMediaConstraints()
            constraints.videoFlag = false
            constraints.audioFlag = true;
            self.localStream = SKWNavigator.getUserMedia(constraints)
        }
        
        //電話をかけた時に走っている
        func call(targetPeerId:String){
            print("=================call=================")
            let option = SKWCallOption()
            // ①mediaConnection接続できた場合のみ
            if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
                self.mediaConnection = mediaConnection //②
                self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
            }else{
                print("failed to call :\(targetPeerId)")
            }
        }
    
    
    }

// MARK: skyway callbacks
extension VoipAcceptUserViewController{
    
    
    func setupPeerCallBacks(peer:SKWPeer){
        // 何らかのエラーが発生した場合に発火します。エラーが発生したら、ログにその内容を表示できるようにします。(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
            print("==================SKWPeerEventEnum.PEER_EVENT_ERROR(1)================")
            if let error = obj as? SKWPeerError{
                // peer.on(.PEER_EVENT_OPEN)のコールバック処理が実行されずにうまく返ってきているようであれば以下でエラー内容が確認できる。
                print("オラオラオラオラ\(error)")
                print("=================SKWPeerEventEnum.PEER_EVENT_ERROR(2)===================")
            }
        })
        
        
        //SkyWayのシグナリングサーバと接続し、利用する準備が整ったら発火します。すべての処理はこのイベント発火後に利用できるようになります。
        //(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
            
            print("=================PEER_EVENT_OPEN(1)=================")
            if let peerId = obj as? String{
                DispatchQueue.main.async {
                    print("work")
                    print("=================PEER_EVENT_OPEN(2)=================")
                    // skywayシグナリングサーバと接続ができたらマッチング相手のpeeridを相手DBへ保存する。
                    self.ref.child("Users").child(self.appDelegate.facebookId).updateChildValues(["peerId": peerId])
                    print("your peerId: \(peerId)")
                    self.call(targetPeerId: self.appDelegate.matchingUserPeerId!)
                }
                
            }
        })
        
        //シグナリングサーバとの接続が切れた際に発火します。(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(.PEER_EVENT_DISCONNECTED) { (obj) -> Void in
            //サーバーと接続が切れたとき
            print("==================シグナリングサーバとの接続が切れよーい===================")
           
        }
   
        
        //Peer（相手）との接続が切れた際に発火します(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(SKWPeerEventEnum.PEER_EVENT_CLOSE) { (obj) -> Void in
            if let test = obj as? String{
                print(test)
                print("==============Peerと接続が切れたとき================")
            }
            self.mediaConnection?.close()
            
        }
        
        
    }
    
    //発電ボタンを押した時に走っている
    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){
        print("=================setupMediaConnectionCallbacks(1)===================")
        // MARK: MEDIACONNECTION_EVENT_STREAM  相手のカメラ、マイク情報を受信したとき
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
            if let msStream = obj as? SKWMediaStream{
                self.remoteStream = msStream
                DispatchQueue.main.async {
                    print("=================setupMediaConnectionCallbacks(2)===================")
                }
            }
            print("=================setupMediaConnectionCallbacks(3)===================")
        })
        
        // 切断されたとき、電話を切った時に走っているMARK: MEDIACONNECTION_EVENT_CLOSE
        // 相手がメディアコネクションの切断処理を実行し、実際に切断されたら発火する(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            print("=================MEDIACONNECTION_EVENT_CLOSE(1)===================")
            if let _ = obj as? SKWMediaConnection{
                DispatchQueue.main.async {
                    //let _ が obj as? SKWMediaConnectionと同じじゃない場合、
                    self.remoteStream = nil
                    self.mediaConnection = nil
                    print("=================MEDIACONNECTION_EVENT_CLOSE(3)===================")
                    
                }
                print("=================MEDIACONNECTION_EVENT_CLOSE(2)===================")
               
            }
        })
        
    }
}


