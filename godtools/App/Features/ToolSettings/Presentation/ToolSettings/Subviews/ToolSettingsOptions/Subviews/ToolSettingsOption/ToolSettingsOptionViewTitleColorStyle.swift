//
//  ToolSettingsOptionViewTitleColorStyle.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

enum ToolSettingsOptionViewTitleColorStyle {
    
    case lightBackground
    case darkBackground
    
    func getColor() -> Color {
        switch self {
        case .lightBackground:
            return Color(.sRGB, red: 84 / 256, green: 84 / 256, blue: 84 / 256, opacity: 1)
        case .darkBackground:
            return Color.white
        }
    }
}
