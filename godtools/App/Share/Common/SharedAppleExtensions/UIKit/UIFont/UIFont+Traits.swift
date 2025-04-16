//
//  UIFont+Traits.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    var bold: UIFont {
        return with(.traitBold)
    }

    var italic: UIFont {
        return with(.traitItalic)
    }

    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }
    
    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        
        guard let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)) else {
            return self
        }
        
        return UIFont(descriptor: descriptor, size: 0)
    }
}
