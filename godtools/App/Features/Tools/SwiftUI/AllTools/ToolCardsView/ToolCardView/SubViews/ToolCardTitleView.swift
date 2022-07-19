//
//  ToolCardTitleView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardTitleView: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(FontLibrary.sfProTextBold.font(size: 18))
            .foregroundColor(ColorPalette.gtGrey.color)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct ToolCardTitleView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCardTitleView(title: "Title Goes Here")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
