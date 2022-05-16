//
//  ToolSettingsOptionItemBackgroundType.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

enum ToolSettingsOptionItemBackgroundType {
    
    case color(color: Color)
    case image(name: String)
    
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
        case .image(let name):
            return Image(name)
        default:
            return nil
        }
    }
}
