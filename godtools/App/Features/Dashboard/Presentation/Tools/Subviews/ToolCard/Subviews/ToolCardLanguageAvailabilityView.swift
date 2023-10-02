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
    private static let textColor = Color.getColorWithRGB(red: 88, green: 170, blue: 66, opacity: 1)
    
    var body: some View {
        
        Text(languageAvailability)
            .font(FontLibrary.sfProTextRegular.font(size: 12))
            .foregroundColor(ToolCardLanguageAvailabilityView.textColor)
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
