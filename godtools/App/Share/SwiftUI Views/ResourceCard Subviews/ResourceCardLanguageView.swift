//
//  ResourceCardLanguageView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ResourceCardLanguageView: View {
    let languageName: String
    
    var body: some View {
        Text(languageName)
            .font(FontLibrary.sfProTextRegular.font(size: 12))
            .foregroundColor(ColorPalette.gtLightGrey.color)
            .lineLimit(1)
    }
}

struct ResourceCardLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceCardLanguageView(languageName: "Arabic (Bahrain) ✓")
            .previewLayout(.sizeThatFits)
    }
}
