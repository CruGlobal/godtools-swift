//
//  MobileContentSpacerView.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentSpacerView: MobileContentView {
    
    private let viewModel: MobileContentSpacerViewModelType
    
    private var heightConstraint: NSLayoutConstraint!
    
    required init(viewModel: MobileContentSpacerViewModelType) {
        
        self.viewModel = viewModel
        
        let height: CGFloat = viewModel.height.fixedHeightValue
    
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height))
        
        heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height
        )
        
        heightConstraint.priority = UILayoutPriority(1000)
        
        addConstraint(heightConstraint)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var height: MobileContentSpacerHeight {
        return viewModel.height
    }
    
    func setHeight(height: CGFloat) {
        heightConstraint.constant = height
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .spacer
    }
}

