//
//  SeparatorView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct SeparatorView: View {
    var body: some View {
        Rectangle()
            .fill(ColorPalette.gtLightestGrey.color)
            .frame(height: 1)
    }
}

struct SeparatorView_Previews: PreviewProvider {
    static var previews: some View {
        SeparatorView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
