//
//  MGPopWindowUtils.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/23.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import MGViewsSwift
import MGUtilsSwift

public class MGPopWindowUtils {

    private var coverView: MGBlankShadowView!
    private var contentView: UIView!

    private var animationUtils = MGAnimationUtils()

    /*
     秀出pop - attr屬性
     content: pop的view
     under: 將出現在這個view下面(同時也是除了content之外不被陰影遮罩的部分(直接取得bounds, 所以是方形))
     highlight: 代表著 under view的 path
     */
    func showPop(_ attr: PopWindowAttr) {

        let window = UIApplication.shared.keyWindow!
        let fullFrame = window.frame

        coverView = MGBlankShadowView(frame: fullFrame)
        coverView?.setOnClickListener { v in
            self.dismiss()
        }
        coverView?.blankPath = attr.highlightPath
        contentView = attr.content

        window.addSubview(coverView)
        window.addSubview(contentView)

        settingContentConstraint(attr)

        display()
    }

    //設定content的約束
    private func settingContentConstraint(_ attr: PopWindowAttr) {

        let window = UIApplication.shared.keyWindow!

        //取得要高亮的 attr.under view在螢幕上的位置
        let underOriginInWindow: CGPoint = (attr.under.superview?.convert(attr.under.frame.origin, to: nil))!

        attr.content.translatesAutoresizingMaskIntoConstraints = false

        //設置顯示的window約束
        //先設置頂端處於哪個位置
        attr.content.topAnchor.constraint(equalTo: window.topAnchor,
                                          constant: underOriginInWindow.y + attr.under.bounds.height).isActive = true

        if attr.widthEqualUnder {
            attr.content.leadingAnchor.constraint(equalTo: attr.under.leadingAnchor).isActive = true
        } else {
            attr.content.widthAnchor.constraint(equalToConstant: attr.width).isActive = true
        }

        attr.content.trailingAnchor.constraint(equalTo: attr.under.trailingAnchor).isActive = true
        attr.content.heightAnchor.constraint(equalToConstant: attr.content.frame.height).isActive = true
    }


    //顯示 view 和 背景黑影
    private func display() {
        let scaleAttr: MGAnimationAttr = MGAnimationAttr(MGAnimationKey.scale, start: 0.7, end: 1)
        let contentAlphaAttr: MGAnimationAttr = MGAnimationAttr(MGAnimationKey.opacity, start: 0, end: 1)
        animationUtils.animator(contentView, attr: [scaleAttr, contentAlphaAttr], duration: 0.2)

        let coverAlphaAttr = MGAnimationAttr(MGAnimationKey.opacity, start: 0, end: 1)
        animationUtils.animator(coverView, attr: [coverAlphaAttr], duration: 0.2)
    }

    //隱藏 view 和 背景黑影 (隱藏後直接移除)
    func dismiss() {
        let scaleAttr: MGAnimationAttr = MGAnimationAttr(MGAnimationKey.scale, start: 1, end: 0.7)
        let contentAlphaAttr: MGAnimationAttr = MGAnimationAttr(MGAnimationKey.opacity, start: 1, end: 0)
        animationUtils.animator(contentView, attr: [scaleAttr, contentAlphaAttr], duration: 0.2, animTag: "contentDismiss") {
            self.contentView.removeFromSuperview()
            self.contentView = nil
        }

        let coverAlphaAttr = MGAnimationAttr(MGAnimationKey.opacity, start: 1, end: 0)
        animationUtils.animator(coverView, attr: [coverAlphaAttr], duration: 0.2, animTag: "coverDismiss") {
            self.coverView.removeFromSuperview()
            self.coverView = nil
        }
    }


    public struct PopWindowAttr {
        let content: UIView
        let under: UIView
        let widthEqualUnder: Bool = true
        let width: CGFloat = 0
        var highlightPath: UIBezierPath!
        var highlightRadius: CGFloat = 0

        init(_ content: UIView, under: UIView, radius: CGFloat = 0) {
            self.content = content
            self.under = under
            self.highlightRadius = radius
            self.highlightPath = generatorUnderViewPath()
        }

        //將view的bound轉為UIBezierPath
        private mutating func generatorUnderViewPath() -> UIBezierPath {
            let underOriginPos = under.superview!.convert(under.frame.origin, to: nil)
            let rect = CGRect(x: underOriginPos.x, y: underOriginPos.y,
                              width: under.frame.width, height: under.frame.height)
            return UIBezierPath.init(roundedRect: rect, cornerRadius: highlightRadius)
        }
    }
}
