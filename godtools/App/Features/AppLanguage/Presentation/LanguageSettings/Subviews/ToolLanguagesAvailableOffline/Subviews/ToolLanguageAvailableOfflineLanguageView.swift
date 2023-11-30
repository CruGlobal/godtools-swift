//
//  ToolLanguageAvailableOfflineLanguageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolLanguageAvailableOfflineLanguageView: View {
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
            
                HStack(alignment: .center, spacing: 11) {
                    
                    Text("English")
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .multilineTextAlignment(.leading)
                    
                    Text("English")
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Text("108.3 MB")
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.leading)
            }
            .padding([.top, .bottom], 15)
            
            SeparatorView()
        }
    }
}
