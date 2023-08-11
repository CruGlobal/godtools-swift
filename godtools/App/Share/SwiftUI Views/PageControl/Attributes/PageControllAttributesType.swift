//
//  PageControllAttributesType.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

protocol PageControlAttributesType {
    
    var deselectedColor: Color { get }
    var selectedColor: Color { get }
    var circleSize: CGFloat { get }
    var circleSpacing: CGFloat { get }
}
