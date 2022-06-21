//
//  RoundedCardBackgroundView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct RoundedCardBackgroundView: View {
    
    // MARK: - Properties
    
    var cornerRadius: CGFloat = 6
    var fillColor: Color = .white
    
    // MARK: - Body
    
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
