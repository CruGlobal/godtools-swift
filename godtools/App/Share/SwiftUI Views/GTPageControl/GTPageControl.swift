//
//  GTPageControl.swift
//  SwiftUIViewEditor (iOS)
//
//  Created by Levi Eggert on 2/16/23.
//

import SwiftUI

struct GTPageControl: View {
    
    let numberOfPages: Int
    let buttonSize: CGFloat = 7.5
    let buttonSpacing: CGFloat = 10
    
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
