//import UserNotifications
//import OneSignal
//
//
//// Notification Service Extensionとは、iOS10から導入されたExtensionで、
//// プッシュ通知を受け取って表示する前に、処理を挟むことができるようになります。
//// たとえば通知を暗号で送って、端末側で複合するとか。(https://toconakis.tech/howto-onesignal/)
//
//class NotificationService: UNNotificationServiceExtension {
//    
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var receivedRequest: UNNotificationRequest!
//    var bestAttemptContent: UNMutableNotificationContent?
//    
//    // 「リモート通知が端末に届いた後」かつ「ユーザーに通知を見せる前」のタイミングで呼ばれる
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        
//        print("=======================didReceiveは走っている=====================")
//        self.receivedRequest = request;
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//        
//        if let bestAttemptContent = bestAttemptContent {
//            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
//            contentHandler(bestAttemptContent)
//        }
//    }
//    
//    // Notification Service app extension が処理を実行できる時間には限りがある。(API Reference によると、30 秒程度)
//    // 時間切れになった場合に app extension がターミネートされる前に呼ばれます。(https://dev.classmethod.jp/smartphone/iphone/user-notifications-framework-13/)
//    // 引数 contentHandler に UNNotificationContent を渡すことによって、その時点でのベストな処理結果をシステム側に提供することができます。
//    override func serviceExtensionTimeWillExpire() {
//      
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
//            contentHandler(bestAttemptContent)
//        }
//    }
//}
