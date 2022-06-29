//
//  BannerTextStyle.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct BannerTextStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(FontLibrary.sfProTextRegular.font(size: 18))
            .multilineTextAlignment(.center)
            .foregroundColor(ColorPalette.gtGrey.color)
    }
}
