//
//  OptionalRoundedBorder.swift
//  godtools
//
//  Created by Rachael Skeath on 5/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OptionalRoundedBorder: ViewModifier {
    @Binding var showBorder: Bool
    var cornerRadius: CGFloat = 6
    let color: Color
    
    func body(content: Content) -> some View {
        
        if showBorder {
            
            content.overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: 2)
            )
            
        } else {
            content
        }
    }
}
