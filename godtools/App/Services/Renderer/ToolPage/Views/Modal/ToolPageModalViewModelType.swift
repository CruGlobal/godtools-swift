//
//  ToolPageModalViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageModalViewModelType {
    
    var backgroundColor: UIColor { get }
    var contentView: MobileContentStackView? { get }
}
