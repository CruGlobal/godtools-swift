//
//  StandardLeadingTrailingMargin.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

enum StandardLeadingTrailingMargin {
    
    static let marginMultiplier: CGFloat = 15/375
    
    static func getMargin(for width: CGFloat) -> CGFloat {
        return width * marginMultiplier
    }
}
