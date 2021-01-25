//
//  ToolTrainingTipView.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingTipView: UICollectionViewCell {
    
    static let nibName: String = "ToolTrainingTipView"
    static let reuseIdentifier: String = "ToolTrainingTipViewReuseIdentifier"
    
    private var tipContentView: MobileContentStackView?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // bottom gradient
        bottomGradientView.isUserInteractionEnabled = false
        bottomGradientView.backgroundColor = .clear
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomGradientView.bounds
        bottomGradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor,
            UIColor.white.cgColor
        ]
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tipContentView?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tipContentView?.setContentInset(contentInset: UIEdgeInsets(top: 0, left: 0, bottom: bottomGradientView.frame.size.height, right: 0))
    }
    
    func configure(contentView: MobileContentStackView?) {
        
        if let contentView = contentView {
            contentStackContainerView.addSubview(contentView)
            contentView.constrainEdgesToSuperview()
        }
        
        tipContentView = contentView
    }
}
