//
//  DisconnectionViewController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/25.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
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

class DisconnectionViewController: UIViewController {
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
    
    
    //このクラスのインスタンスをreportNewIncomingCallメソッドを呼び出すことで着信画面を表示している。
    let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "ainomy"))
    let UUIDs = UUID()
    let callUpdate = CXCallUpdate()
    let controller = CXCallController()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
       ref = Database.database().reference()

       loadImage()
       phoneImage()
       matchingName()
       indicatorView()
       setup()
//        let transaction = CXTransaction(action: CXStartCallAction(call: UUIDs, handle: CXHandle(type: .generic, value: "ainomy")))
//
//                self.controller.request(transaction){ error in
//                    if let error = error {
//                        print("Error requesting transaction: \(error)")
//                    } else {
//                        print("Requested transaction successfully") // Error Domain=com.apple.CallKit.error
//                        // setupメソッドでskywayシグナリングサーバへアクセス
//                         self.setup()
//                    }
//                }
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
        // 設定済みをマーク.
        peer?.disconnect()
        endCall(call: UUIDs)
        mediaConnection?.close()
        
        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "MatchUser")
        self.present(nextView, animated: false, completion: nil)
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
    // (https://github.com/ninjaprox/NVActivityIndicatorView)
    func indicatorView(){
        // インジケータの追加
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 30), type: NVActivityIndicatorType.ballBeat, color: UIColor.lightGray, padding: 0)
        activityIndicatorView.center = self.view.center // 位置を中心に設定
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        activityIndicatorView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15.0).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func endCall(call: UUID) {
        // シグナリングサーバと端末の間のコネクションが切断されるとpeer.on(.PEER_EVENT_DISCONNECTED)が呼ばれる
        
        
        let endCallAction = CXEndCallAction(call: call)
        let transaction = CXTransaction(action: endCallAction)
        controller.request(transaction) { error in
            if let error = error {
                print("EndCallAction transaction request failed: \(error.localizedDescription).")
                let reason = CXCallEndedReason.remoteEnded
                self.provider.reportCall(with: call, endedAt: nil, reason: reason)

                return
            }
            
            print("EndCallAction transaction request successful")
            
        }
        
    }
 
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//         timer.invalidate()
        peer?.disconnect()
        endCall(call: UUIDs)
        print("====ここでnilが出力されてた=====")
    }
    

}

// MARK: setup skyway
extension DisconnectionViewController{
    
    func setup(){
        print("================func setup()====================")
        // 以下でappdelegareファイルからskywayのAPI情報を取得してapikey変数に代入(http://sona.hateblo.jp/entry/2018/02/19/210000)
        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
            print("Not set apikey or domain")
            return
        }
        
    
        // 以下の処理でskywayレンダリングサーバに通信して任意のpeeridを作成している
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = apikey
        option.domain = domain
        
        peer = SKWPeer(options: option)
        // 自分のpeer_idを生成できていたら、
        if let _peer = peer{
            // 以下メソッド発火
            self.setupPeerCallBacks(peer: _peer)
            // 自分のカメラの映像を取得して表示メディアを取得(https://github.com/skyway/webrtc-handson-native/wiki/2.3.%E3%83%A1%E3%83%87%E3%82%A3%E3%82%A2%E3%81%AE%E5%8F%96%E5%BE%97)
             self.setupStream(peer: _peer)
        }else{
            print("failed to create peer setup")
        }
    }
    // 自分のカメラの映像を取得して表示メディアを取得(https://github.com/skyway/webrtc-handson-native/wiki/2.3.%E3%83%A1%E3%83%87%E3%82%A3%E3%82%A2%E3%81%AE%E5%8F%96%E5%BE%97)
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
extension DisconnectionViewController{
    
    
    func setupPeerCallBacks(peer:SKWPeer){
        // 何らかのエラーが発生した場合に発火します。エラーが発生したら、ログにその内容を表示できるようにします。(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
            print("==================SKWPeerEventEnum.PEER_EVENT_ERROR(1)================")
         
            if let error = obj as? SKWPeerError{
                // peer.on(.PEER_EVENT_OPEN)のコールバック処理が実行されずにうまく返ってきているようであれば以下でエラー内容が確認できる。
                print("SKWPeerEventEnum.PEER_EVENT_ERROR\(error)")
                self.endCall(call: self.UUIDs)
                peer.disconnect()
                self.mediaConnection?.close()
             
            }
        })
        
        
        //SkyWayのシグナリングサーバと接続し、利用する準備が整ったら発火します。すべての処理はこのイベント発火後に利用できるようになります。
        //(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
            
            print("=================PEER_EVENT_OPEN(1)=================")
            if let peerId = obj as? String{
                DispatchQueue.main.async {
                    print("取得したPeerId：\(peerId)")
                    print("=================PEER_EVENT_OPEN(2)=================")
                    // skywayシグナリングサーバと接続ができたらマッチング相手のpeeridを相手DBへ保存する。
                    self.ref.child("Users").child(self.appDelegate.facebookId).updateChildValues(["peerId": peerId])
                    
                    // ====================Onesignal_Voip通知====================
                    let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
                    
                    // https://documentation.onesignal.com/docs/ios-native-sdk
                    OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
                    
                    // Recommend moving the below line to prompt for push after informing the user about
                    //   how your app will use them.
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        // voip受け取り手がvoip受診後に走る処理
                        print("User accepted notifications: \(accepted)")
                    })
                    
                    // 以下のコマンドでvoip通知を送信している。
                    print("=====matchingUserVoipId!=====\(self.appDelegate.matchingUserVoipId!)====================")
                    // include_player_idsに通話相手のidを入力
                    OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [self.appDelegate.matchingUserVoipId!]])
                    // ====================Onesignal_Voip通知====================
                   
                }
                
            }
        })
        
        //シグナリングサーバとの接続が切れた際に発火します。(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(.PEER_EVENT_DISCONNECTED) { (obj) -> Void in
            //サーバーと接続が切れたとき
            print("==================シグナリングサーバとの接続が切れたほい===================")
            self.endCall(call: self.UUIDs)
            self.mediaConnection?.close()
            
        }
        
        
        
        //let update = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: "ainomy")
        self.callUpdate.supportsDTMF = true
        self.callUpdate.supportsHolding = false
        self.callUpdate.supportsGrouping = false
        self.callUpdate.supportsUngrouping = false
        self.callUpdate.hasVideo = false
        
        
        //相手から接続要求が来た場合に発火 (https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in
            print("===============PEER_EVENT_CALL(1)==================")
            
                if let connection = obj as? SKWMediaConnection{
                    self.setupMediaConnectionCallbacks(mediaConnection: connection)
                    self.mediaConnection = connection
                    //ここで応答！！
                    connection.answer(self.localStream)
                    // インジケーターを止める
                    self.activityIndicatorView.stopAnimating()
                    // 相手が電話を取った時にタイマーを走らせる処理
//                    self.startTimer()
                }
            
            print("===============PEER_EVENT_CALL(2)==================")
        })
        
        //Peer（相手）との接続が切れた際に発火します(https://webrtc.ecl.ntt.com/ios-tutorial.html)
        peer.on(.PEER_EVENT_CLOSE) { (obj) -> Void in
            print("==============Peerと接続が切れたとき================")
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
        
        
        // 相手がメディアコネクションの切断処理を実行し、実際に切断されたら発火する(https://webrtc.ecl.ntt.com/ios-tutorial.html#call-event)
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            print("=================MEDIACONNECTION_EVENT_CLOSE(1)===================")
            if let _ = obj as? SKWMediaConnection{
                DispatchQueue.main.async {
                    //let _ が obj as? SKWMediaConnectionと同じじゃない場合、
                    self.remoteStream = nil
                    self.mediaConnection = nil
                    print("=================MEDIACONNECTION_EVENT_CLOSE(3)===================")
                    //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "MatchUser")
                    self.present(nextView, animated: false, completion: nil)
                    
                }
                print("=================MEDIACONNECTION_EVENT_CLOSE(2)===================")
                // 発電側で電話が切れた場合はアラートを出力させる
                
            }
        })
        
    }
}




