//
//  UIImage+Trimming.swift
//  FacebookLoginTest
//
//  Created by kishirinichiro on 2018/10/05.
//  Copyright © 2018年 kishirinichiro. All rights reserved.
//

import UIKit

//トリミングを行うメソッド
//トリミング範囲の大きさcroppingRectと元画像の大きさとの拡大倍率をzoomedInOutScaleを用いる
extension UIImage {
    func trimming(to trimmingRect : CGRect , zoomedInOutScale: CGFloat) -> UIImage? {
        var opaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: trimmingRect.size.width/zoomedInOutScale, height: trimmingRect.size.height/zoomedInOutScale), opaque, scale)
        draw(at: CGPoint(x: -trimmingRect.origin.x/zoomedInOutScale, y: -trimmingRect.origin.y/zoomedInOutScale))
        let trimmedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return trimmedImage
    }
}

