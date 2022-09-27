//
//  AccordionView.swift
//  godtools
//
//  Created by Rachael Skeath on 9/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccordionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            SeparatorView()
            
            Text("Conversation Starters")
                .font(FontLibrary.sfProTextBold.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
            
            SeparatorView()
        }
    }
}

struct AccordionView_Previews: PreviewProvider {
    static var previews: some View {
        AccordionView()
            .padding()
    }
}
