//
//  SpotlightTitleView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct SpotlightTitleView: View {
        
    let title: String
    let subtitle: String
        
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            
            Text(title)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
            Text(subtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
        }
    }
}

// MARK: - Preview

struct SpotlightTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightTitleView(title: "Title Goes Here", subtitle: "Subtitle goes here")
            .previewLayout(.sizeThatFits)
    }
}
