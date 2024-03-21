//
//  ToolSettingsOptionViewBackground.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

enum ToolSettingsOptionViewBackground {
    
    case color(color: Color)
    case image(image: Image)
    
    func getColor() -> Color {
        switch self {
        case .color(let color):
            return color
        case .image( _):
            return Color.clear
        }
    }
    
    func getImage() -> Image? {
        switch self {
        case .image(let image):
            return image
        default:
            return nil
        }
    }
}
