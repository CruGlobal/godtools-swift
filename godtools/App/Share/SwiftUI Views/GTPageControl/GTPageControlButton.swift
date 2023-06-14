//
//  GTPageControlButton.swift
//  SwiftUIViewEditor (iOS)
//
//  Created by Levi Eggert on 2/16/23.
//

import SwiftUI

struct GTPageControlButton: View {
    
    let page: Int
    let deselectedColor: Color = Color.getColorWithRGB(red: 230, green: 230, blue: 230, opacity: 1)
    let selectedColor: Color = ColorPalette.gtBlue.color
    let size: CGFloat
    
    @Binding var currentPage: Int
    
    var body: some View {
        
        Button(action: {
            
            currentPage = page
        }) {
            
            Circle()
                .fill(currentPage == page ? selectedColor : deselectedColor)
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size, alignment: .center)
    }
}
