//
//  ToolCategoryButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoryButtonView: View {
    var body: some View {
        ZStack {
            RoundedCardBackgroundView()
            
            Text("Conversation Starter")
                .font(FontLibrary.sfProTextBold.font(size: 18))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 160, height: 74)
    }
}

struct ToolCategoryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCategoryButtonView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
