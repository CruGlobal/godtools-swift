//
//  LessonProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 4/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import SwiftUI

protocol LessonProgressViewDelegate: AnyObject {
    
    func lessonProgressViewCloseTapped(progressView: LessonProgressView)
}

class LessonProgressView: UIView {
    
    private let progressView: DownloadProgressView = DownloadProgressView(frame: .zero)
    private let closeButton: UIButton = UIButton(type: .custom)
    
    private var isAttachedToParent: Bool = false
    
    private weak var delegate: LessonProgressViewDelegate?
    
    let height: CGFloat
    
    init(layoutDirection: UISemanticContentAttribute) {
        
        let height: CGFloat = 64
        
        self.height = height
        
        super.init(frame: CGRect(x: 0, y: 0, width: 414, height: height))
        
        setupLayout()
        
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        
        let scaleX: CGFloat = layoutDirection == .forceRightToLeft ? -1.0 : 1.0
        
        transform = CGAffineTransform(scaleX: scaleX, y: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addChildViews()
        
        progressView.progressCornerRadius = 6
        progressView.progressBackgroundColor = Color.getUIColorWithRGB(red: 238, green: 236, blue: 238, opacity: 1)
        progressView.progressColor = Color.getUIColorWithRGB(red: 59, green: 164, blue: 219, opacity: 1)
    }
    
    private func addChildViews() {
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(progressView)
        addSubview(closeButton)
                
        closeButton.setImage(ImageCatalog.navClose.uiImage, for: .normal)
        _ = closeButton.addWidthConstraint(constant: 50)
        _ = closeButton.addHeightConstraint(constant: 50)
        closeButton.constrainCenterVerticallyInView(view: self)
        closeButton.constrainRightToView(view: self, constant: 10)
        
        _ = progressView.addHeightConstraint(constant: 12)
        progressView.constrainCenterVerticallyInView(view: self)
        progressView.constrainLeftToView(view: self, constant: 70)
        
        let progressViewRightToCloseButton: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .right,
            relatedBy: .equal,
            toItem: closeButton,
            attribute: .left,
            multiplier: 1,
            constant: -10
        )
        
        addConstraint(progressViewRightToCloseButton)
    }
    
    @objc func handleCloseTapped() {
        delegate?.lessonProgressViewCloseTapped(progressView: self)
    }
    
    func setDelegate(delegate: LessonProgressViewDelegate?) {
        self.delegate = delegate
    }
    
    func setProgress(progress: CGFloat, animated: Bool) {
     
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.progressView.progress = progress
            } completion: { (finished: Bool) in
                
            }
        }
        else {
            progressView.progress = progress
        }
    }
}

extension LessonProgressView {
    
    func attachToParent(viewController: UIViewController, safeAreaView: UIView) {
        
        guard !isAttachedToParent else {
            return
        }
        
        isAttachedToParent = true
        
        let parentView: UIView = viewController.view
        let progressView: LessonProgressView = self
        
        parentView.addSubview(progressView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let left: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .left,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .left,
            multiplier: 1,
            constant: 0
        )
        
        let right: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .right,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .right,
            multiplier: 1,
            constant: 0
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .top,
            relatedBy: .equal,
            toItem: safeAreaView,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        parentView.addConstraint(left)
        parentView.addConstraint(right)
        parentView.addConstraint(top)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: progressView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: progressView.height
        )
        
        heightConstraint.priority = UILayoutPriority(1000)
        
        progressView.addConstraint(heightConstraint)
    }
}
