//
//  ToolCardLanguageAvailabilityView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardLanguageAvailabilityView: View {
    
    let languageAvailability: String
    
    var body: some View {
        
        Text(languageAvailability)
            .font(FontLibrary.sfProTextRegular.font(size: 12))
            .foregroundColor(ColorPalette.gtLightGrey.color)
            .truncationMode(.middle)
            .lineLimit(1)
    }
}

// MARK: - Preview

struct ToolCardLanguageAvailabilityView_Preview: PreviewProvider {
    
    static var previews: some View {
       
        ToolCardLanguageAvailabilityView(
            languageAvailability: "English"
        )
    }
}
