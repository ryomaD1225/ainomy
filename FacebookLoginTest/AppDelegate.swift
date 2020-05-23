//
//  AppDelegate.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/05.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookCore
import FirebaseDatabase
import UserNotifications
import FirebaseMessaging
import OneSignal

//追加
import CallKit
import PushKit
import SkyWay


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
        var genderText:String!
        var numberpeopleText:String!
        var facebookId:String!
        var matchingGender:String!
        var matchingUserVoipId:String!
        let userDefaults = UserDefaults.standard
    
    
        //new
        var matchingUserAge:Int!
        var matchingUserName:String!
        var matchingUserJob:String!
        var matchingUserImagePath : String!
        var photoLibraryImage : UIImage! //これで取得した写真を保持
        var peerId:String!
        var matchingUserPeerId:String!
        var userIntroducing:String!
    
        var myPeerId:SKWPeer?
    //    // タイマー処理を継続させる　https://qiita.com/SatoTakeshiX/items/8e1489560444a63c21e7
        var backgroundTaskID : UIBackgroundTaskIdentifier = 0
    
        //skyway用インストール
        var skywayAPIKey:String? = "707da128-efc0-4fa5-8bef-7cd83e64d489"
        var skywayDomain:String? = "localhost"
    
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
    

    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // ユーザーに通知の許可を要求します。→ UNUserNotificationCenter
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        // registerForRemoteNotificationsメソッドAPNsを使ったpush通知用のデバイストークンを要求。
        // 成功するとdidRegisterForRemoteNotificationsWithDeviceTokenが呼び出される
        // 失敗するとdidFailToRegisterForRemoteNotificationsWithErrorが呼び出される
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        return true
    }
    
    // [START receive_message]
    // push通知を受け取った際にアプリがバックグラウンド時であれば以下のコールバックは呼び出されない。
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    // push通知を受け取った際にアプリがバックグラウンド時であれば以下のコールバックは呼び出されない。
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    // 何かしらの問題でpush通知用のデバイストークンが届かない時に以下の処理が走る
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // デバッグ用で追加されているからswizzlingしてたら消して良いよー
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    // メソッドの実装入れ替えを無効にしていれば以下のメソッドを実装必要があるよ。
    //(https://qiita.com/ysk_1031/items/e0fce5ec0c31c0ede0d6)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        Messaging.messaging().apnsToken = deviceToken
    
        print("Messaging.messaging().apnsToken\(Messaging.messaging().apnsToken!)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            completionHandler([.alert, .sound])
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, CXProviderDelegate, PKPushRegistryDelegate {
//
//
//
//    var window: UIWindow?
//    var genderText:String!
//    var numberpeopleText:String!
//    var facebookId:String!
//    var matchingGender:String!
//    var matchingUserVoipId:String!
//    let userDefaults = UserDefaults.standard
//
//
//    //new
//    var matchingUserAge:Int!
//    var matchingUserName:String!
//    var matchingUserJob:String!
//    var matchingUserImagePath : String!
//    var photoLibraryImage : UIImage! //これで取得した写真を保持
//    var peerId:String!
//    var matchingUserPeerId:String!
//    var userIntroducing:String!
//
//    var myPeerId:SKWPeer?
//    // タイマー処理を継続させる　https://qiita.com/SatoTakeshiX/items/8e1489560444a63c21e7
//    var backgroundTaskID : UIBackgroundTaskIdentifier = 0
//
//
//    //skyway用インストール
//    var skywayAPIKey:String? = "707da128-efc0-4fa5-8bef-7cd83e64d489"
//    var skywayDomain:String? = "localhost"
//
//    //skywayで利用するインスタンス(オブジェクト)変数の宣言
//    fileprivate var peer: SKWPeer? //①//Peerオブジェクト
//    fileprivate var mediaConnection: SKWMediaConnection?//②MediaConnectionオブジェクト
//    fileprivate var localStream: SKWMediaStream? //自分自身のMediaStreamオブジェクト
//    fileprivate var remoteStream: SKWMediaStream?//相手のMediaStreamオブジェクト
//
//
//    //このクラスのインスタンスをreportNewIncomingCallメソッドを呼び出すことで着信画面を表示している。
//    let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "ainomy"))
//    let UUIDs = UUID()
//    let callUpdate = CXCallUpdate()
//    let controller = CXCallController()
//
//
//
//    override init() {
//        super.init()
//        //FirebaseApp 共有インスタンスを設定します。
//        FirebaseApp.configure()
//
//        print("\(UUIDs)========UUIDs=======")
//        print("\(UUID())========UUID=======")
//
//    }
//
//    func registerForPushNotifications() {
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//            (granted, error) in
//            print("Permission granted: \(granted)")
//            // 1. Check if permission granted
//            guard granted else { return }
//            // 2. Attempt registration for remote notifications on the main thread
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
//
//
//    //アプリを再起動とかしてもここは最初しか呼ばれない
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        // PushKit
//        let registry = PKPushRegistry(queue: nil)
//        registry.delegate = self
//        registry.desiredPushTypes = [PKPushType.voIP]
//
//
//        //  Converted to Swift 4 by Swiftify v4.1.6781 - https://objectivec2swift.com/
//        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//
//        //追加コード
//        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//
//
//        //これで、ユーザーが初回にアプリを立ち上げるとプッシュ通知の許可ダイアログが出る
//        //push通知のための追加コード
//        if #available(iOS 10.0, *) {didReceiveRemoteNotification
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        print("============走っているよ==============")
//        application.registerForRemoteNotifications()
//        print("============走っているよ==============")
//    // アプリ起動時にFCMのトークンを取得し、表示する
//        let token = Messaging.messaging().fcmToken
//
//
//        print("FCM token: \(token ?? "")")
//
//        //userIdがあったらfcmTokenと一緒にポストする
//        UserDefaults.standard.set(token, forKey: "FCM_TOKEN")
////        print("Firebase registration token: \(token!)")
//
//        Messaging.messaging().delegate = self
//
//
//        Messaging.messaging().isAutoInitEnabled = true
//
//        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
//
//
//        OneSignal.initWithLaunchOptions(launchOptions,
//                                        appId: "ea6c89cd-2b2c-4e76-9d3f-bfc4f8f3352c",
//                                        handleNotificationAction: nil,
//                                        settings: onesignalInitSettings)
//
//
//        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
//
//        OneSignal.promptForPushNotifications(userResponse: { accepted in
//            print("User accepted notifications: \(accepted)")
//        })
//
//        // 以下のコマンドでvoip通知を送信している。
////        OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": ["ac27aeca-166d-422a-80ce-016ae5178891"]])
//
//      registerForPushNotifications()
//        return true
//    }
//
//    // 明示的にAPNsトークンをFCM登録トークンにマッピング(https://qiita.com/ysk_1031/items/e0fce5ec0c31c0ede0d6)
//    // 関連する全ての処理が正しく処理されたら以下のメソッドが走る
//    func application(application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("deviceToken\(deviceToken)")
//        Messaging.messaging().apnsToken = deviceToken
//
//        print("Messaging.messaging().apnsToken\(Messaging.messaging().apnsToken!)")
//    }
//
//    // 何か処理にエラーがあれば以下のメソッドが呼ばれる
//    func application( application: UIApplication!,
//                      didFailToRegisterForRemoteNotificationsWithError error: NSError! ) {
//        // エラー処理
//        print("デバイストークンがAPNsに登録されてない: \(error!)")
//    }
//
//    // Handle updated push credentials
//    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
//        // Register VoIP push token (a property of PKPushCredentials) with server
//    }
//
//
//
//    // 正しくないprovisining fileでsigninした際に呼ばれる
//    func application(_ application: UIApplication,
//    didFailToRegisterForRemoteNotificationsWithError error: Error) {
//    print("Oh no! Failed to register for remote notifications with error \(error)")
//    }
//
//    //ここは特に動いていない(push通知)
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//
//
//        //userIdがあったらfcmTokenと一緒にポストする
//        UserDefaults.standard.set(fcmToken, forKey: "FCM_TOKEN")
//        print("Firebase registration token: \(fcmToken)")
//
//        // TODO: If necessary send token to application server.
//        // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
//
//    //ここは特に動いていない(push通知)
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
//
//    //  Converted to Swift 4 by Swiftify v4.1.6781 - https://objectivec2swift.com/
//    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
//        // Add any custom logic here.
//        return handled
//    }
//
//
//
//    //アプリ閉じそうな時に呼ばれる
//    func applicationWillResignActive(_ application: UIApplication) {
//
//        self.backgroundTaskID = application.beginBackgroundTask(){
//            [weak self] in
//            application.endBackgroundTask((self?.backgroundTaskID)!)
//            self?.backgroundTaskID = UIBackgroundTaskInvalid
//        }
//    }
//
//    //アプリを閉じた時に呼ばれる
//    func applicationDidEnterBackground(_ application: UIApplication) {
//
//    }
//
//    //アプリを開きそうな時に呼ばれる
//    func applicationWillEnterForeground(_ application: UIApplication) {
//
//        print("=====ここが最初=====")
//    }
//
//    //アプリを開いた時に呼ばれる
//    func applicationDidBecomeActive(_ application: UIApplication) {
//
//        application.endBackgroundTask(self.backgroundTaskID)
//    }
//
//    //フリックしてアプリを終了させた時に呼ばれる
//    func applicationWillTerminate(_ application: UIApplication) {
//        print("==========キャッシュクリアしてアプリを終了するよ============")
//        // アプリの終了時にクリアした時間を保持して、再アプリ起動時に「クリア時間」と「マッチ時間」を比較するように使用する
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        let displayTime = formatter.string(from: Date())
//        saveClearTime(str: displayTime)
//    }
//
//    //追加コード
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        return SDKApplicationDelegate.shared.application(application,
//                                                         open: url,
//                                                         sourceApplication: sourceApplication,
//                                                         annotation: annotation)
//    }
//
//    // サイレント通知を受け取った場合以下のメソッドで通知を受け取ります。
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        print("受信時に走るよ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
//        // Print message ID.
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//
//        // Print full message.
//        print(userInfo)
//    }
//
//    // サイレントを受信したら以下メソッドが走るからこの中でデータ更新などの処理を記述
//    // (http://www.cl9.info/entry/2017/10/14/145342)
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print("受信時に走るよ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
//        // Print message ID.
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//        // Print full message.
//        print(userInfo)
//
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
//
//    //callkitのために追加
//    func providerDidReset(_ provider: CXProvider) {
//    }
//
//
//    ///callkitのために追加 アプリ起動時に毎回呼ばれる(自分が観測した限りでは)
//    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//        print(pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined())
//        // UserDefaultsにデバイストークンを保存
//        UserDefaults.standard.set(pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined(), forKey: "DEVICE_TOKEN")
//        print("ここの上がでデバイストークン")
//
//    }
//
//
//    // VoIPプッシュ通知受信ハンドリング callkitのために追加
//    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
//        // voip通知を受け取ったらskywayシグナリングへ通信
//        provider.setDelegate(self, queue: nil)
//
//        var ref: DatabaseReference!
//        let user = Auth.auth().currentUser
//
//        // ③マッチ相手のpeeridと接続する
//        ref = Database.database().reference()
//        // 自分のUUIDをDBへ保存
////        let myUUID = UUIDs.description
////        ref.child("Users").child((user?.uid)!).updateChildValues(["UUID": myUUID])
//        saveTimerData(str: "false")
//        // 電話を接続するために自分のDBからマッチング相手のpeeridを取得
//        ref.child("Users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let items = snapshot.value as! [String: Any]
//            print("============ここまでいけてる================")
//            // マッチング相手のpeeridを取得する
//            self.matchingUserPeerId = items["peerId"]! as? String
//            self.setup()
//        // peerid取得に失敗したら以下の処理が走る,setup()も処理されないので何かしらの処理を施す
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
//
//    // callkit 電話取るボタンを押したら以下の処理が走る
//    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
//
//        action.fulfill()
//
//        print("=================CXAnswerCallAction============")
//
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        //　Storyboardを指定
//        let storyboard = UIStoryboard(name: "VoipAcceptUser", bundle: nil)
//        // Viewcontrollerを指定
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "VoipAcceptUser")
//        // rootViewControllerに入れる
//        self.window?.rootViewController = initialViewController
//        // 表示
//        self.window?.makeKeyAndVisible()
//
//    }
//
//
//    //callkitの × ボタンを押したら以下の処理が走る。　発電側のcallkitの出力を止めないといけない
//    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
//        self.mediaConnection?.close()
//        peer?.disconnect()
//        print("=================CXEndCallAction============")
//        action.fulfill()
//
//    }
//
//    func saveTimerData(str: String){
//        // Keyを指定して保存
//        userDefaults.set(str, forKey: "stopTimer")
//
//    }
//
//    func saveClearTime(str: String){
//        // Keyを指定して保存
//        userDefaults.set(str, forKey: "clearTime")
//
//    }
//
//}
//// Onesignalからpush通知を送信した時は以下のメソッドが走っている
//// (https://dev.classmethod.jp/smartphone/iphone/wwdc-2016-user-notifications-7/)
//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//    // モバイルアプリがフォアグラウンドで動作中にメッセージを受信したときに呼ばれる。
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        let message = "相手が見つかりました。"
//
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//            print("push通知テスト①")
//            completionHandler([.alert, .sound])
//
//        }
//
//
//        print(userInfo)
//
//
//
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//            print("push通知テスト②")
//        }
//
//        print(userInfo)
//
//
//    }
//}
//
//
//// MARK: setup skyway
//extension AppDelegate{
//
//    func setup(){
//        print("================func setup()====================")
//        // 以下でappdelegareファイルからskywayのAPI情報を取得してapikey変数に代入(http://sona.hateblo.jp/entry/2018/02/19/210000)
//        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
//            print("Not set apikey or domain")
//            return
//        }
//
//        // 以下の処理でskywayレンダリングサーバに通信して任意のpeeridを作成している
//        let option: SKWPeerOption = SKWPeerOption.init();
//        // apikey所持
//        option.key = apikey
//        // domain情報保持
//        option.domain = domain
//
//        // 自身のpeeridを取得する
//        peer = SKWPeer(options: option)
//
//        if let _peer = peer{
//            self.setupPeerCallBacks(peer: _peer)
//            self.setupStream(peer: _peer)
//            myPeerId = _peer
//        }else{
//            // peerid生成に失敗したらcallkitを表示させないようにここで処理を終わらせる！ + 発電側にも電話が繋がらない表示をさせる！
//            print("failed to create peer setup")
//        }
//    }
//
//    func setupStream(peer:SKWPeer){
//        print("=================setupStream=================")
//        SKWNavigator.initialize(peer);
//        let constraints:SKWMediaConstraints = SKWMediaConstraints()
//        constraints.videoFlag = false
//        constraints.audioFlag = true;
//        self.localStream = SKWNavigator.getUserMedia(constraints)
//    }
//
//    //電話をかけた時に走っている
//    func call(targetPeerId:String){
//        print("=================call=================")
//        let option = SKWCallOption()
//        // ①mediaConnection接続できた場合のみ
//        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
//
//            self.mediaConnection = mediaConnection //②
//            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
//
//
//            // これで電話のUIが出ます。
//            print("reportNewIncomingCall：\(self.UUIDs)")
//            provider.reportNewIncomingCall(with: self.UUIDs, update: callUpdate, completion: { error in
//
//                if let error = error {
//                    print("reportNewIncomingCallエラーを出力: \(error)")
//
//                } else {
//                    print("=================reportNewIncomingCall成功===================")
//                }
//            })
//
//            print("\(self.UUIDs)========UUIDs=======")
//
//        }else{
//
//            print("failed to call :\(targetPeerId)")
//            // callkitUIの出力に失敗したら通信を強制解除して通話を終わらせる
//            peer?.disconnect()
//        }
//    }
//
//    func moveToUserImageView(){
//
//        //　windowを生成
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        //　Storyboardを指定
//        let storyboard = UIStoryboard(name: "MatchUser", bundle: nil)
//        // Viewcontrollerを指定
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MatchUser")
//        // rootViewControllerに入れる
//        self.window?.rootViewController = initialViewController
//        // 表示
//        self.window?.makeKeyAndVisible()
//    }
//
//
//
//    func endCall(call: UUID) {
//
//        let endCallAction = CXEndCallAction(call: call)
//        let transaction = CXTransaction(action: endCallAction)
//        controller.request(transaction) { error in
//            if let error = error {
//                print("EndCallAction transaction request failed: \(error.localizedDescription).")
//
//                self.provider.reportCall(with: call, endedAt: nil, reason: .remoteEnded)
//
//                return
//            }
//
//            print("EndCallAction transaction request successful")
//            self.mediaConnection?.close()
//        }
//
//    }
//}
//
//
//
//
//
//
//
//
//
//// MARK: skyway callbacks
//extension AppDelegate{
//
//
//    func setupPeerCallBacks(peer:SKWPeer){
//
//        //SkyWayのすべての処理はこのイベント発火後に利用できるようになります。(https://webrtc.ecl.ntt.com/ios-tutorial.html#eventlistener)
//        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
//            print("=================PEER_EVENT_OPEN(1)=================")
//            if let peerId = obj as? String{
//                print("==========自分のpeer_id：\(peerId)")
//                DispatchQueue.main.async {
//                    print("=================PEER_EVENT_OPEN(2)=================")
//                    // シグナリングサーバへ通信が成功したらマッチング相手に電話をかける
//                    print("\(self.matchingUserPeerId!)===========self.matchingUserPeerId!")
//                    self.call(targetPeerId: self.matchingUserPeerId!)
//
//                }
//            }
//        })
//
//        //シグナリングサーバとの接続が切れた際に発火します。(https://webrtc.ecl.ntt.com/ios-tutorial.html#eventlistener)
//        //シグナリングサーバとの接続が切れた際に発火します。(https://webrtc.ecl.ntt.com/ios-tutorial.html)
//        peer.on(.PEER_EVENT_DISCONNECTED) { (obj) -> Void in
//            //サーバーと接続が切れたとき
//            print("==================シグナリングサーバとの接続が切れたほい\(self.UUIDs)===================")
//            self.endCall(call: self.UUIDs)
//            self.mediaConnection?.close()
//            self.moveToUserImageView()
//        }
//
//        // 相手から接続要求が来た場合に発火 (https://webrtc.ecl.ntt.com/ios-tutorial.html#eventlistener)
//        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in
//            print("===============PEER_EVENT_CALL(1)==================")
//
//        })
//
//        //Peer（相手）との接続が切れた際に発火します(https://webrtc.ecl.ntt.com/ios-tutorial.html#eventlistener)
//        peer.on(SKWPeerEventEnum.PEER_EVENT_CLOSE) { (obj) -> Void in
//            print("==============Peerと接続が切れたとき================")
//
//        }
//
//
//        // 何らかのエラーが発生した場合に発火します。エラーが発生したら、ログにその内容を表示できるようにします。(https://webrtc.ecl.ntt.com/ios-tutorial.html)
//        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
//            print("==================SKWPeerEventEnum.PEER_EVENT_ERROR(1)================")
//            if let error = obj as? SKWPeerError{
//                // peer.on(.PEER_EVENT_OPEN)のコールバック処理が実行されずにうまく返ってきているようであれば以下でエラー内容が確認できる。
//                print("PEER_EVENT_ERROR transaction request failed；\(error)")
//                peer.disconnect()
//                self.mediaConnection?.close()
//                self.endCall(call: self.UUIDs)
//            }
//        })
//
//
//
//
//
//        callUpdate.remoteHandle = CXHandle(type: .generic, value: "ainomy")
//        self.callUpdate.supportsDTMF = true
//        self.callUpdate.supportsHolding = false
//        self.callUpdate.supportsGrouping = false
//        self.callUpdate.supportsUngrouping = false
//        self.callUpdate.hasVideo = false
//
//
//
//
//
//    }
//
//
//    //発電ボタンを押した時に走っている
//    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){
//        print("=================setupMediaConnectionCallbacks(1)===================")
//        // MARK: MEDIACONNECTION_EVENT_STREAM  相手のカメラ、マイク情報を受信したとき
//        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
//            if let msStream = obj as? SKWMediaStream{
//                print("=================setupMediaConnectionCallbacks(2)===================")
//                self.remoteStream = msStream
//                DispatchQueue.main.async {
//
//                }
//            }
//            print("=================setupMediaConnectionCallbacks(3)===================")
//        })
//
//        // 切断されたとき、電話を切った時に走っているMARK: MEDIACONNECTION_EVENT_CLOSE
//        // 相手がメディアコネクションの切断処理を実行し、実際に切断されたら発火する(https://webrtc.ecl.ntt.com/ios-tutorial.html)
//        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
//
//            print("=================MEDIACONNECTION_EVENT_CLOSE(1)===================")
//            if let _ = obj as? SKWMediaConnection{
//                DispatchQueue.main.async {
//                    //let _ が obj as? SKWMediaConnectionと同じじゃない場合、
//                    self.remoteStream = nil
//                    self.mediaConnection = nil
//                    print("=================MEDIACONNECTION_EVENT_CLOSE(3)===================")
//                }
//
//                self.peer?.disconnect()
//
//                let endCallAction = CXEndCallAction(call: self.UUIDs)
//                let transaction2 = CXTransaction(action: endCallAction)
//
//                self.controller.request(transaction2) { (error) in
//
//                    print("your UUIDs①：\(self.UUIDs)====================")
//
//                    if let error = error {
//
//                        self.endCall(call:self.UUIDs)
//                        print("your UUIDs②: \(self.UUIDs)")
//                        print("エラーを出力: \(error)")
//                        self.provider.reportCall(with: self.UUIDs, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
//                        print("=================MEDIACONNECTION_EVENT_CLOSE 失敗===================")
//                        return
//                    } else {
//                        print("your UUIDs③：\(self.UUIDs)====================")
//                        print("=================MEDIACONNECTION_EVENT_CLOSE 成功===================")
//                        // 電話を切断された時に前の画面へ遷移する処理
//
//                        self.moveToUserImageView()
//                    }
//                }
//            }
//        })
//
//    }
//}
//
