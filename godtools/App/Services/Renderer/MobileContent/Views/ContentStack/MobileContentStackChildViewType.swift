//
//  MobileContentStackChildViewType.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentStackChildViewDelegate: class {
    
    func contentStackChildViewHeightDidChange(contentStackChildView: MobileContentStackChildViewType, heightAmountChanged: CGFloat)
}

protocol MobileContentStackChildViewType: class {
    
    var view: UIView { get }
    var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType { get }
    var contentStackChildViewDelegate: MobileContentStackChildViewDelegate? { get set }
}

extension MobileContentStackChildViewType {
    func setDelegate(delegate: MobileContentStackChildViewDelegate?) {
        self.contentStackChildViewDelegate = delegate
    }
}
