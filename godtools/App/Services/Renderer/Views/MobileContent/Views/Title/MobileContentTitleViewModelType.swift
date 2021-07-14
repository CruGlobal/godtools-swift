//
//  MobileContentTitleViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentTitleViewModelType: MobileContentViewModelType {
    
    var fontSize: CGFloat { get }
    var fontWeight: UIFont.Weight { get }
    var textColor: UIColor { get }
    var lineSpacing: CGFloat { get }
}
