//
//  ToolCardCategoryView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardCategoryView: View {
    
    let category: String
    
    var body: some View {
        
        Text(category)
            .font(FontLibrary.sfProTextRegular.font(size: 14))
            .foregroundColor(ColorPalette.gtGrey.color)
    }
}

// MARK: - Preview

struct ToolCardCategoryView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        ToolCardCategoryView(category: "Category Text")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
