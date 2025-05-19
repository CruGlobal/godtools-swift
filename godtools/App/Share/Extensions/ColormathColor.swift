//
//  ColormathColor.swift
//  godtools
//
//  Created by Daniel Frett on 5/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import GodToolsToolParser
import UIKit

extension ColormathColor {
    func toUIColor() -> UIColor {
        return ColorKt.__toUIColor(self)
    }
}
