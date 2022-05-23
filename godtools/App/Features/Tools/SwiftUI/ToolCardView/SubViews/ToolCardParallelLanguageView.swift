//
//  ToolCardParallelLanguageView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardParallelLanguageView: View {
    let languageName: String
    
    var body: some View {
        Text(languageName)
            .font(FontLibrary.sfProTextRegular.font(size: 12))
            .foregroundColor(ColorPalette.gtLightGrey.color)
    }
}

struct ToolCardParallelLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCardParallelLanguageView(languageName: "Arabic (Bahrain) ✓")
            .previewLayout(.sizeThatFits)
    }
}
