//
//  RoundedCardBackgroundView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct RoundedCardBackgroundView: View {
        
    let cornerRadius: CGFloat
    let fillColor: Color
    
    init(cornerRadius: CGFloat = 6, fillColor: Color = .white) {
        
        self.cornerRadius = cornerRadius
        self.fillColor = fillColor
    }
        
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
            .fill(fillColor)
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }
}

// MARK: - Preview

struct RoundedCardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedCardBackgroundView()
            .padding()
    }
}
