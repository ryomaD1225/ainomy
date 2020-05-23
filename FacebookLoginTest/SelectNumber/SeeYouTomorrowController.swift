//
//  SeeYouTomorrowController.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/11/27.
//  Copyright © 2018 kishirinichiro. All rights reserved.
//

import UIKit

class SeeYouTomorrowController: UIPresentationController {
    
    // 呼び出し元のView Controller の上に重ねるオーバレイView
    var overlayView = UIView()
    var backHomeButton = UIButton()
    
    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        
        
        guard let containerView = containerView else {
            return
        }
        //overlayViewは薄暗く靄がかったところ
        overlayView.frame = containerView.bounds
        // ここをコメントアウトしたらう黒い部分タッチ時にviewがdismissしなくなる。
        overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.overlayViewDidTouch(_:)))]
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)
        
        // トランジションを実行
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.7
            }, completion:nil)
    }
    
    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion:nil)
    }
    
    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }
    
    let margin = (x: CGFloat(30), y: CGFloat(220.0))
    
    // 子のコンテナサイズを返す
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - margin.x, height: parentSize.height - margin.y)
    }
    
    // 呼び出し先のView Controllerのframeを返す
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect()
        let containerBounds = containerView!.bounds
        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = childContentSize
        presentedViewFrame.origin.x = margin.x / 2.0
        presentedViewFrame.origin.y = margin.y / 2.0
        
        return presentedViewFrame
    }
    
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        presentedView?.backgroundColor = .white
        overlayView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 10
        presentedView?.clipsToBounds = true
    }
    
    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
        backButton()
    }
    
    // overlayViewをタップした時に呼ばれる
    @objc func overlayViewDidTouch(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    func backButton(){
        // サイズを変更する
        backHomeButton.frame = CGRect(x: 0, y: 0, width: containerView!.bounds.width-50, height: 50)
        
        // 任意の場所に設置する
        backHomeButton.layer.position = CGPoint(x: overlayView.frame.width/2-15, y:overlayView.frame.height/2+20)
        
        // 文字色を変える
        backHomeButton.setTitleColor(UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1), for: UIControlState.normal)
        
        // 背景色を変える
        backHomeButton.backgroundColor = .white
        
        // 枠の太さを変える
        backHomeButton.layer.borderWidth = 1.0
        
        // 枠の色を変える
        backHomeButton.layer.borderColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1).cgColor
        
        // 枠に丸みをつける
        backHomeButton.layer.cornerRadius = 10
        
        // ボタンのタイトルを設定
        backHomeButton.setTitle("ここに今日はもぉ使えないですよと表記", for:UIControlState.normal)
        
        // タップされたときのaction
        backHomeButton.addTarget(self,
                                 action: #selector(buttonTapped(sender:)),
                                 for: .touchUpInside)
        
        // Viewにボタンを追加
        self.presentedView?.addSubview(backHomeButton)
        
    }
    
    @objc func buttonTapped(sender: UIButton) {
        print("押してるよ")
        presentedViewController.dismiss(animated: true, completion: nil)
        
    }

}
