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
    
    func transparentModalDidLayout()
}
