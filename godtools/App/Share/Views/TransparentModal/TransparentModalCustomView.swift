//
//  TransparentModalCustomView.swift
//  godtools
//
//  Created by Levi Eggert on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TransparentModalCustomView {
    
    var modal: UIView { get }
    var modalInsets: UIEdgeInsets { get }
    var modalLayoutType: TransparentModalCustomViewLayoutType { get }
    
    func addToParentForCustomLayout(parent: UIView)
    func transparentModalDidLayout()
    func transparentModalParentWillAnimateForPresented()
    func transparentModalParentWillAnimateForDismissed()
}
