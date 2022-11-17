//
//  DownloadProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class DownloadProgressView: UIControl, NibBased {
    
    private var isLoaded: Bool = false
    
    @IBInspectable var progressBackgroundColor: UIColor = UIColor(red: 218 / 255, green: 218 / 255, blue: 227 / 255, alpha: 1) {
        didSet {
            if isLoaded {
                progressBackgroundView?.backgroundColor = progressBackgroundColor
            }
        }
    }
    
    @IBInspectable var progressColor: UIColor = UIColor(red: 0 / 255, green: 214 / 255, blue: 143 / 255, alpha: 1) {
        didSet {
            if isLoaded {
                progressBar.backgroundColor = progressColor
            }
        }
    }
    
    @IBInspectable var progressCornerRadius: CGFloat = 0 {
        didSet {
            progressBackgroundView?.layer.cornerRadius = progressCornerRadius
            progressBar.layer.cornerRadius = progressCornerRadius
        }
    }
    
    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            if isLoaded {
                if progress < 0 {
                    progress = 0
                } else if progress > 1 {
                    progress = 1
                }
                let totalProgress: CGFloat = bounds.size.width
                var progressFrame: CGRect = progressBar.frame
                progressFrame.size.width = totalProgress * progress
                progressBar.frame = progressFrame
                sendActions(for: .valueChanged)
            }
        }
    }
    
    @IBOutlet weak private var progressBar: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
        isLoaded = true
        backgroundColor = .clear
        progressCornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressBar.frame = bounds
        let currentProgress: CGFloat = progress
        progress = currentProgress
    }
    
    private var progressBackgroundView: UIView? {
        return subviews.first
    }
}
