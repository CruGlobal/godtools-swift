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
    
    private var tipView: UIView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tipView?.removeFromSuperview()
        tipView = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tipView?.frame = contentView.bounds
    }
    
    func configure(tipView: UIView) {
        
        self.tipView = tipView
        
        contentView.addSubview(tipView)
    }
}
