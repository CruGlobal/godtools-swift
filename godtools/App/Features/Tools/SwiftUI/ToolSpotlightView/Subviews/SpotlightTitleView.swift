//
//  SpotlightTitleView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct SpotlightTitleView: View {
    
    // MARK: - Properties
    
    let title: String
    let subtitle: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(title)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
            Text(subtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 12))
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
