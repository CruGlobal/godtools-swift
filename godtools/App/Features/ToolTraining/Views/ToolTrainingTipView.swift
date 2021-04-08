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
    
    private var mobileContentView: MobileContentView?
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mobileContentView?.removeFromSuperview()
        mobileContentView = nil
    }
    
    func configure(mobileContentView: MobileContentView) {
            
        contentView.addSubview(mobileContentView)
        mobileContentView.constrainEdgesToSuperview()
        self.mobileContentView = mobileContentView
    }
}
