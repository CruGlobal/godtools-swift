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
    
    private var mobileContentView: LegacyMobileContentView?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mobileContentView?.removeFromSuperview()
        mobileContentView = nil
    }
    
    func configure(mobileContentView: LegacyMobileContentView) {
            
        let parentView: UIView = contentView
        parentView.addSubview(mobileContentView)
        mobileContentView.translatesAutoresizingMaskIntoConstraints = false
        mobileContentView.constrainEdgesToView(view: parentView)
        self.mobileContentView = mobileContentView
    }
}
