//
//  UserImageViewController.swift
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
import Photos
// 画像トリミングライブラリ
import CropViewController

class UserImageViewController: UIViewController {
    
    var ref:DatabaseReference?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //=========UserDefaults のインスタンス========
    let userDefaults = UserDefaults.standard
    
    
    // カメラまたは写真から画像を選択したか？
    private var imageSelected = false
    //ページコントロールのための変数を定義
    var pageControl = UIPageControl()
    // ボタンのインスタンス生成
    let button = UIButton()
    //ナビゲーションバーを作る
    let navBar = UINavigationBar()
    
     var imageView: UIImageView!
     var UserImage:UILabel!
     var width:CGFloat = 0
     var height:CGFloat = 0
     var scale:CGFloat = 1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        ref = Database.database().reference()
        
        setTest()
        initImageView()
        setupPageControl()
        nextButton()
        backButton()
        

    }
    
    func setTest() {
        UserImage = UILabel()
        UserImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        UserImage.text = """
        プロフィール写真を
        設定してください
        """
        UserImage.textAlignment = NSTextAlignment.center
        UserImage.numberOfLines = 2
        UserImage.sizeToFit()
        UserImage.center = self.view.center
        UserImage.frame.origin.y = UserImage.frame.origin.y - 200
        self.view.addSubview(UserImage)
        
        
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
//        let rect:CGRect = CGRect(x:0, y:0, width:width*scale-50, height:height*scale-50)
        let rect:CGRect = CGRect(x:0, y:0, width:width*scale-200, height:height*scale-200)

        //ImgaeView FrameをCGRectで作った矩形に合わせる
        imageView.frame = rect;

        // 画像の中心を画面の中心に設定
//        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2 )
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2 - 30 )
        // 角丸にする
//        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.clipsToBounds = true

        // ジェスチャーの生成
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)

        //画像を選んだ後にこのファイルで表示したい
        if(appDelegate.photoLibraryImage != nil ){
            imageView.image = appDelegate.photoLibraryImage
            // 設定済みをマーク.
            self.imageSelected = true

            imageView.frame = rect
            //縦横の比率をそのままに長い辺を基準に全体表示（※空白が発生する可能性あり）(http://www.sirochro.com/note/swift-view-ratio-list/)
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)

        }

    }
    
    func backButton(){
        let items = UIBarButtonItem(barButtonHiddenItem: .Back, target: nil, action: #selector(self.myAction))
        //xとyで位置を、widthとheightで幅と高さを指定する http://tech-tokyobay.manju.tokyo/archives/727
        self.navBar.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44)
        self.navBar.barTintColor = .white
        //ナビゲーションアイテムのタイトルを設定
        let navItem : UINavigationItem = UINavigationItem(title: "プロフィール登録")
        
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
    
    func setupPageControl() {
        
        let label2 = UILabel(frame: CGRect(x: self.view.frame.width/2, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label2.text = " STEP2";
        label2.sizeToFit();
        label2.layer.position = CGPoint(x: self.view.frame.width/2, y:UserImage.frame.origin.y - 50)
        
        label2.textColor = UIColor.black
        self.view.addSubview(label2);
        
        let label1 = UILabel(frame: CGRect(x:label2.frame.origin.x - 75, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label1.text = "STEP1  >";
        label1.sizeToFit();
        label1.textColor = UIColor.black
        self.view.addSubview(label1);
        
        
        let label3 = UILabel(frame: CGRect(x:label2.frame.origin.x + 65, y:UserImage.frame.origin.y - 60, width:0, height:20));
        label3.text = ">  STEP3";
        label3.sizeToFit();
        label3.textColor = UIColor.black
        self.view.addSubview(label3);
        
    }
    
    // ジェスチャーイベント処理
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("ジェスチャーイベント処理")
        
        // アルバムが利用可能かをチェック.
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
            self.showAlert(message: "アルバムは利用できません。")
            return
        }
        
        // アルバムを起動.
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        //        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    func nextButton(){
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        // サイズを変更する
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        // 任意の場所に設置する
        button.layer.position = CGPoint(x: self.view.frame.width/2, y:screenHeight - 100)
        
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
        button.setTitle("次へ", for:UIControlState.normal)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
        
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        if imageSelected == false {
            self.showAlert(message: "画像が選択されていません。")
        }else{
            sendImageDate()
            saveImage()
            let storyboard: UIStoryboard = UIStoryboard(name: "FinalConfirmation", bundle: nil)
            let UserInfo = storyboard.instantiateInitialViewController()
            self.present(UserInfo!, animated: true, completion: nil)
        }
    }
    
    //①ディレクトリのURLを指定
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let DocumentDirectoryFileURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    
    //②保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "localData.png"
        print("==documentDirectoryFileURL:\(documentDirectoryFileURL)")
        print("==DocumentDirectoryFileURL:\(DocumentDirectoryFileURL)")
        
        // DocumentディレクトリのfileURLを取得
        if documentDirectoryFileURL != nil {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let path = documentDirectoryFileURL.appendingPathComponent(fileName)
            documentDirectoryFileURL = path
            print("-------------------")
            print("書き込むファイルのパス: \(String(describing: path))")
            print("-------------------")
        }
    }
    
    
    //③画像を保存する関数の部分
    func saveImage() {
        createLocalDataFile()
        //pngで保存する場合
        let pngImageData = UIImagePNGRepresentation(imageView.image!)
        do {
            try pngImageData!.write(to: documentDirectoryFileURL)
            //local端末にデータを保存
            userDefaults.set(documentDirectoryFileURL, forKey: "userImage")
            print("-------------------")
            print("サクセス！")
            print("-------------------")
        } catch {
            //エラー処理
            print("-------------------")
            print("エラー")
            print("-------------------")
        }
    }
    

    func sendImageDate(){
        
        let user = Auth.auth().currentUser
        let storage = Storage.storage()
        let storageRef = storage.reference()
     
        //UIImagePNGRepresentationでUIImageをNSDataに変換
        if let data = UIImagePNGRepresentation(imageView.image! ){
            
            let reference = storageRef.child("images/" + (user?.uid)! + ".jpg")
            print("=========================================")
            print(reference) // gs://gokon-9a08a.appspot.com/images/9W7tZxxzcjN2sZ5Hn1AzgmXHgUK2.jpg
            
            //FIRStorageReference.putData(...)でアップロードしています。
            reference.putData(data, metadata: nil, completion: { metaData, error in
             
                // Fetch the download URL
                reference.downloadURL { url, error in
                    // Get the download URL for 'images/'
                    guard let downloadURL = url else {
                        print("失敗ーーーーーーーーーーーーーーーー！")
                        // Uh-oh, an error occurred!
                        return
                    }
                    print("成-------------------功！")
                    
                    let deta = downloadURL.absoluteString
                 
                    if let uid = user?.uid{
                        self.ref?.child("Users").child(uid).updateChildValues(["image":deta])
                    }
                    
                }
                print(metaData as Any)
                print(error as Any)

            })
        }
    }

}

// UIImagePickerController で必要なので実装（具体的な処理は不要なので中身はない）.
extension UserImageViewController: UINavigationControllerDelegate {}

// カメラor写真で画像が選択された時などの処理を実装する.
extension UserImageViewController: UIImagePickerControllerDelegate {
    
    // カメラor写真で画像が選択された
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
 
        // ユーザーがカメラで撮影した or 写真から選んだ、画像がある場合. 
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //AppDelegateファイルで定義している変数でデータを保持。
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.photoLibraryImage = image
            
            print("走っているよーーーーーーーーーーーーーーー")
           
            let cropViewController = CropViewController(croppingStyle: .circular, image: image)
            cropViewController.delegate = self as? CropViewControllerDelegate
            picker.present(cropViewController, animated: true, completion: nil)
            

        }
        
        
    }
}


extension UserImageViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        //加工した画像が取得できる
        print("OK")
        
        //AppDelegateファイルで定義している変数でデータを保持。
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.photoLibraryImage = image
        // 下の画面に戻る
        let storyboard: UIStoryboard = UIStoryboard(name: "UserImage", bundle: nil)
        let UserInfo = storyboard.instantiateInitialViewController()
        cropViewController.present(UserInfo!, animated: true, completion: nil)

    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        // キャンセル時
        cropViewController.dismiss(animated: true, completion: nil)
        print("cancel")
    }
}


