//
//  ToolCardBackgroundView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardBackgroundView: View {
    
    // MARK: - Properties
    
    let cornerRadius: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
            .fill(.white)
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }
}

// MARK: - Preview

struct ToolCardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCardBackgroundView(cornerRadius: 6)
            .padding()
    }
}
