//
//  ToolDetailsVersionsCardView.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsCardView: View {
    
    @State var isSelected: Bool = false
    
    var body: some View {
        
        VStack {
            
            Image("tutorial_tool_non_english")
            
            HStack(alignment: .top, spacing: 0) {
                
                CircleSelectorView(isSelected: $isSelected)
                    .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0))
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: 16)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Hello World")
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextSemibold.font(size: 19))
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 5)
                    
                    Text("Connecting with God is a version of the Four Spiritual Laws adapted for high schoolers. This version contains updated language and visuals that appeal to a younger audience.")
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 35)
                    
                    HStack(alignment: .top, spacing: 5) {
                        Spacer()
                        Text("30 Languages")
                        Text("|")
                        Text("French")
                        Text("|")
                        Text("English")
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                    .foregroundColor(ColorPalette.gtLightGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 13))
                }
            }
            .padding(EdgeInsets(top: 15, leading: 25, bottom: 0, trailing: 25))
        }
    }
}

struct ToolDetailsVersionsCardView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ToolDetailsVersionsCardView()
    }
}
