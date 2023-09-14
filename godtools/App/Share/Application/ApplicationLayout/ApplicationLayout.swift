//
//  ApplicationLayout.swift
//  godtools
//
//  Created by Levi Eggert on 9/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class ApplicationLayout {
    
    private(set) static var direction: ApplicationLayoutDirection = .leftToRight
    
    init() {
        
    }
    
    static func setLayoutDirection(direction: ApplicationLayoutDirection) {
        
        ApplicationLayout.direction = direction
        
        // Globablly set all UIKit UIView's to flip direction for language.  This appears to apply to UINavigationController navigation push and pop as well. ~Levi
        UIView.appearance().semanticContentAttribute = direction.uiKit
    }
}
