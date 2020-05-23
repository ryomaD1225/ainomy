//
//  TrimmingVC.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/11/16.
//  Copyright © 2018 kishirinichiro. All rights reserved.
//

import UIKit
import Foundation

class TrimmingVC: UIViewController {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var finishEditingButton: UIButton! //編集の終了
    @IBOutlet weak var editPhotoView: UIView! //トリミングで残す範囲を可視化するためのUIView
    @IBOutlet weak var headerView: UIView!
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var image : UIImage!
    var imageView : UIImageView! //トリミング対象画像を表示するためのUIImageView
    var previousImages = [UIImage]()
    var nextImages = [UIImage]()
    var scaleZoomedInOut : CGFloat = 1.0 //拡大・縮小した時にはUIImageViewのサイズのみが変わるので、実際のUIImageのサイズとUIImageViewとの倍率の差を記録する
    var previousScaleZoomedInOut = [CGFloat]()
    var nextScaleZoomedInOut = [CGFloat]()
    // ドキュメントディレクトリの「ファイルURL」（URL型）
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //=========UserDefaults のインスタンス========
    let userDefaults = UserDefaults.standard
    
    var str: CGFloat!
    var test: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        finishEditingButton.addTarget(self, action: #selector(finishEdittingAlert), for: .touchUpInside)
        
        editPhotoView.layer.borderColor = UIColor.black.cgColor
        editPhotoView.layer.borderWidth = 1
        setUpPinchInOutAndDoubleTap()
        
        //load image and show UIImageView
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        image = appDelegate.photoLibraryImage
        previousScaleZoomedInOut.append(scaleZoomedInOut)
        createImageView(sourceImage: image, on: editPhotoView)
        mainStackView.bringSubview(toFront: headerView)
    }
    
    //ピンチイン/アウト・ダブルタップの検出
    func setUpPinchInOutAndDoubleTap(){
        // ピンチイン・アウトの準備
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(gesture:)))
        pinchGetsture.delegate = self as? UIGestureRecognizerDelegate
        
        self.editPhotoView.isUserInteractionEnabled = true
        self.editPhotoView.isMultipleTouchEnabled = true
        
        self.editPhotoView.addGestureRecognizer(pinchGetsture)
        // ダブルタップの準備
        let doubleTapGesture = UITapGestureRecognizer(target: self, action:#selector(doubleTapAction(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.editPhotoView.addGestureRecognizer(doubleTapGesture)
    }
    
    //UIImageViewのサイズを画面の横幅に合わせたサイズに調整しているのを画面の高さに合わせたサイズに調整するよう修正
    //画像の全体が把握できるように、画像本体（UIImage）の幅がスクリーンの幅よりも大きい時は、画像を画面の幅に合わせたUIImageViewとして表示するという処理を施す関数
    func createImageView(sourceImage: UIImage, on parentView: UIView){
        imageView = UIImageView(image: sourceImage)
        // 画像の幅・高さの取得
        let imageWidth = sourceImage.size.width
        let imageHeight = sourceImage.size.height
        
        print("高さ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
        
        //トリミングする枠の情報を取得
        let screenWidth = editPhotoView.frame.width
        let screenHeight = editPhotoView.frame.height
        
        
        //修正前
        //        if scaleZoomedInOut == 1.0{
        //            if imageWidth > screenWidth{
        //                scaleZoomedInOut = screenWidth/imageWidth
        //            }
        //        }
        
        //修正後
        if scaleZoomedInOut == 1.0{
            if imageHeight > screenHeight{
                scaleZoomedInOut = screenHeight/imageHeight
            }
        }
        
        let rect:CGRect = CGRect(x:0, y:0, width:scaleZoomedInOut*imageWidth, height:scaleZoomedInOut*imageHeight)
        str = scaleZoomedInOut*imageWidth
        print(str)
        print("str------------------------------")
        
        test = scaleZoomedInOut*imageHeight
        print(test)
        print("test------------------------------")
        imageView.frame = rect// ImageView frame をCGRectで作った矩形に合わせる
        imageView.contentMode = .scaleAspectFill // Aspect Fill = 縦横の比率はそのままで短い辺を基準に全体を表示する
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2) // 画像の中心をスクリーンの中心位置に設定
        
        //カスタマイズViewを追加
        parentView.addSubview(imageView)
        parentView.sendSubview(toBack: imageView)
    }
    
    func updateImageView(){
        imageView.removeFromSuperview()
        createImageView(sourceImage: image, on: editPhotoView)
    }
    
    //上下左右の移動は、ドラッグ操作で行えるようにする。
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // タッチイベントを取得.
        let aTouch: UITouch = touches.first!
        
        // 移動した先の座標を取得.
        let location = aTouch.location(in: editPhotoView)
        
        // 移動する前の座標を取得.
        let prevLocation = aTouch.previousLocation(in: editPhotoView)
        
        //移動した距離
        let deltaX = location.x - prevLocation.x
        let deltaY = location.y - prevLocation.y
        
        
        imageView.frame.origin.x += deltaX
        imageView.frame.origin.y += deltaY
        
        //        if imageView.frame.origin.y < 0{
        //            imageView.frame.origin.y = 0
        //        }else if imageView.frame.origin.y > 0{
        //            imageView.frame.origin.y = 0
        //        }else if imageView.frame.origin.x > 0{
        //            imageView.frame.origin.x = 0
        //        }else if editPhotoView.frame.size.width > (imageView.frame.size.width + imageView.frame.origin.x){
        //            print("ウェウ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
        //            print(editPhotoView.frame.size.width) //トリム枠のwidth
        //            print(imageView.frame.size.width + imageView.frame.origin.x) //画像幅と画像の一番左(マイナス)を足した数
        //            print(imageView.frame.size.width) //画像幅
        //            print(imageView.frame.origin.x)   //画像幅のスタート地点
        //
        //            imageView.frame.origin.x += editPhotoView.frame.size.width - (imageView.frame.size.width + imageView.frame.origin.x)
        //        }
        
    }
    
    //トリミングする。はみ出ていないところだけが残る。
    func makeTrimmingRect(targetImageView: UIImageView, trimmingAreaView: UIView) -> CGRect?{
        var width = CGFloat()
        var height = CGFloat()
        var trimmingX = CGFloat()
        var trimmingY = CGFloat()
        
        let deltaX = targetImageView.frame.origin.x
        let deltaY = targetImageView.frame.origin.y
        
        //空の部分ができてしまった場合、その部分を切り取る
        
        var xNotTrimFlag = false
        //x方向
        if targetImageView.frame.width > trimmingAreaView.frame.width {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if targetImageView.frame.origin.x > 0{
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //上方向にはみ出し
                width = trimmingAreaView.frame.size.width - deltaX
            }else{
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if trimmingAreaView.frame.size.width > (targetImageView.frame.size.width + targetImageView.frame.origin.x) {
                    width = targetImageView.frame.size.width + targetImageView.frame.origin.x
                }else{
                    //下方向もはみ出し
                    width = trimmingAreaView.frame.size.width
                }
            }
        }else{
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if targetImageView.frame.origin.x > 0{
                if trimmingAreaView.frame.size.width < (targetImageView.frame.size.width + targetImageView.frame.origin.x) {
                    //下方向にはみ出し
                    width = trimmingAreaView.frame.size.width - deltaX
                }else{
                    xNotTrimFlag = true
                    width = targetImageView.frame.size.width
                }
            }else{
                //上方向にはみ出し
                width = targetImageView.frame.size.width + targetImageView.frame.origin.x
            }
        }
        //y方向
        if targetImageView.frame.height > trimmingAreaView.frame.height {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if targetImageView.frame.origin.y > 0{
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //下方向にはみ出し
                height = trimmingAreaView.frame.size.height - deltaY
            }else{
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if trimmingAreaView.frame.size.height > (targetImageView.frame.size.height + targetImageView.frame.origin.y) {
                    height = targetImageView.frame.size.height + targetImageView.frame.origin.y
                }else{
                    //下方向もはみ出し
                    height = trimmingAreaView.frame.size.height
                }
            }
        }else{
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if targetImageView.frame.origin.y > 0{
                if trimmingAreaView.frame.size.height < (targetImageView.frame.size.height + targetImageView.frame.origin.y) {
                    //下方向にはみ出し
                    height = trimmingAreaView.frame.size.height - deltaY
                }else{
                    if xNotTrimFlag {
                        return nil
                    }else{
                        height = targetImageView.frame.size.height
                    }
                }
            }else{
                //上方向にはみ出し
                height = targetImageView.frame.size.height + targetImageView.frame.origin.y
            }
        }
        
        //trimmingRectの座標を決定
        if targetImageView.frame.origin.x > trimmingAreaView.frame.origin.x {
            trimmingX = 0
        }else{
            trimmingX = -deltaX
        }
        
        if targetImageView.frame.origin.y > 0 {
            trimmingY = 0
        }else{
            trimmingY = -deltaY
        }
        
        return CGRect(x: trimmingX, y: trimmingY, width: width, height: height)
    }
    
    @objc func finishEdittingAlert(){
        let alert = UIAlertController(title: "確認",
                                      message: "編集を終了して画像を保存しますか？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "保存", style: .cancel) { (_) -> Void in
            self.finishEditing()
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default))
        self.present(alert, animated: true)
    }
    
    //はみ出したところを切り出す
    @objc func trimImage(){
        if let trimmingRect = makeTrimmingRect(targetImageView: imageView, trimmingAreaView: editPhotoView){
            image = image.trimming(to: trimmingRect, zoomedInOutScale: scaleZoomedInOut)
            updateImageView()
        }
    }
    
    func finishEditing(){
        saveUserImage()
        trimImage()
        saveImage()
        moveToNextPage()
    }
    
    //②保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "localData.png"
        print("==documentDirectoryFileURL:\(documentDirectoryFileURL)")
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
    func saveUserImage() {
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
    
    func saveImage(){
        //AppDelegateファイルで定義している変数でデータを保持。
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.photoLibraryImage = image
    }
    
    func moveToNextPage(){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPage") as! MyPageViewController
        self.present(secondViewController, animated: true)
        
    }
    
    
    var pichCenter : CGPoint!
    var touchPoint1 : CGPoint!
    var touchPoint2 : CGPoint!
    let maxScale : CGFloat = 1
    var pinchStartImageCenter : CGPoint!
    
    @objc func pinchAction(gesture: UIPinchGestureRecognizer) {
        
        
        if gesture.state == UIGestureRecognizerState.began {
            // ピンチを開始したときの画像の中心点を保存しておく
            pinchStartImageCenter = imageView.center
            touchPoint1 = gesture.location(ofTouch: 0, in: self.view)
            touchPoint2 = gesture.location(ofTouch: 1, in: self.view)
            
            // 指の中間点を求めて保存しておく
            // UIGestureRecognizerState.Changedで毎回求めた場合、ピンチ状態で片方の指だけ動かしたときに中心点がずれておかしな位置でズームされるため
            pichCenter = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2, y: (touchPoint1.y + touchPoint2.y) / 2)
            
        } else if gesture.state == UIGestureRecognizerState.changed {
            // ピンチジェスチャー・変更中
            print("ここだよ１") //縮小すると動く箇所
            var pinchScale :  CGFloat// ピンチを開始してからの拡大率。差分ではない
            
            
            if gesture.scale > 1 {
                pinchScale = 1 + gesture.scale/100
                print("ここだよ2")
            }else{
                pinchScale = gesture.scale
                print("ここだよ3") //縮小すると動く箇所
            }
            if pinchScale*self.imageView.frame.width < editPhotoView.frame.width {
                pinchScale = editPhotoView.frame.width/self.imageView.frame.width
                print("ここだよ4")
            }
            
            scaleZoomedInOut *= pinchScale
            print("ここだよ5") //縮小すると動く箇所
            // ピンチした位置を中心としてズーム（イン/アウト）するように、画像の中心位置をずらす
            let newCenter = CGPoint(x: pinchStartImageCenter.x - ((pichCenter.x - pinchStartImageCenter.x) * pinchScale - (pichCenter.x - pinchStartImageCenter.x)),y: pinchStartImageCenter.y - ((pichCenter.y - pinchStartImageCenter.y) * pinchScale - (pichCenter.y - pinchStartImageCenter.y)))
            
            self.imageView.frame.size = CGSize(width: pinchScale*self.imageView.frame.width, height: pinchScale*self.imageView.frame.height)
            print(type(of: pinchScale*self.imageView.frame.width))
            print("type(of: pinchScale*self.imageView.frame.width")
            print(type(of: str!))
            
            
            print("ここだよ6") //縮小すると動く箇所
            imageView.center = newCenter
            
            //追記
            let newWidth = pinchScale*self.imageView.frame.width
            print(newWidth)
            print("newWidth===========================")
            let newHeight = pinchScale*self.imageView.frame.height
            print(newHeight)
            print("newhight===========================")
            //追記
            
            if newWidth <= str && newHeight <= test {
                //ここでnilが入っている
                self.imageView.frame.size = CGSize(width: str!, height: test!)
                
                print(self.imageView.frame.size)
                print("動いているよ＝＝＝＝＝＝＝＝＝＝＝＝＝")
                //                self.imageView.center = CGPoint(x:editPhotoView.frame.width/2, y:editPhotoView.frame.height/2)
                self.imageView.center = CGPoint(x:editPhotoView.frame.width/2, y:editPhotoView.frame.height/2)
                
            }
            
        }
    }
    
    //ダブルタップは、ダブルタップを行うとタップをしたところを中心にUIImageViewが２倍の大きさになる
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.ended {
            
            let doubleTapStartCenter = imageView.center
            let doubleTapScale: CGFloat = 2.0 // ダブルタップでは現在のスケールの2倍にする
            scaleZoomedInOut *= doubleTapScale
            let tapPoint = gesture.location(in: self.view)
            let newCenter = CGPoint(x:
                doubleTapStartCenter.x - ((tapPoint.x - doubleTapStartCenter.x) * doubleTapScale - (tapPoint.x - doubleTapStartCenter.x)),
                                    y: doubleTapStartCenter.y - ((tapPoint.y - doubleTapStartCenter.y) * doubleTapScale - (tapPoint.y - doubleTapStartCenter.y)))
            
            // 拡大・縮小とタップ位置に合わせた中心点の移動
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.imageView.frame.size = CGSize(width: doubleTapScale*self.imageView.frame.width, height: doubleTapScale*self.imageView.frame.height)
                self.imageView.center = newCenter
            }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
