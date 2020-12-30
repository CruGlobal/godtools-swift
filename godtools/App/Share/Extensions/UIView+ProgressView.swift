//
//  UIView+ProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIView {
    
    static func setProgress(progress: Double, progressView: UIView, progressViewWidth: NSLayoutConstraint, maxProgressViewWidth: CGFloat, layoutView: UIView, animated: Bool) {
                
        if progress == 0 {
            progressViewWidth.constant = 0
            progressView.alpha = 0
            layoutView.layoutIfNeeded()
            return
        }
        
        progressViewWidth.constant = CGFloat(Double(maxProgressViewWidth) * progress)
        progressView.alpha = 1
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                layoutView.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            layoutView.layoutIfNeeded()
        }
        
        if progress == 1 {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                progressView.alpha = 0
            }, completion: nil)
        }
    }
}
