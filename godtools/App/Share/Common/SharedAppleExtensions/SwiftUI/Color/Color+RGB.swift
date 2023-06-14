//
//  Color+RGB.swift
//  SharedAppleExtensions
//  
//
//  Created by Rachael Skeath on 3/28/23.
//

import Foundation
import SwiftUI

public extension Color {
    
    static func getColorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) -> Color {
        Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255, opacity: opacity)
    }
    
    static func getUIColorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) -> UIColor {
        return UIColor(Color.getColorWithRGB(red: red, green: green, blue: blue, opacity: opacity))
    }
}
