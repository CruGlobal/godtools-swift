//
//  GTPageControl.swift
//  SwiftUIViewEditor (iOS)
//
//  Created by Levi Eggert on 2/16/23.
//

import SwiftUI

struct GTPageControl: View {
    
    let numberOfPages: Int
    let buttonSize: CGFloat = 10
    let buttonSpacing: CGFloat = 8
    
    @Binding var currentPage: Int
    
    var body: some View {
        
        HStack(alignment: .center, spacing: buttonSpacing) {
            
            ForEach((0 ..< numberOfPages), id: \.self) { index in
                
                GTPageControlButton(page: index, size: buttonSize, currentPage: $currentPage)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
