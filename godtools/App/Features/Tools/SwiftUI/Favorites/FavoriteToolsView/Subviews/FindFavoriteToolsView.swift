//
//  FindFavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FindFavoriteToolsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: FavoriteToolsViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.sRGB, red: 243/256, green: 243/256, blue: 243/256, opacity: 1)
            
            VStack(spacing: 4) {
                Text("No favorite tools to display")
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                Text("Tap on the heart icon to favorite a tool and make it available offline.")
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                GTBlueButton(title: "Go To Tools", fontSize: 12, width: 118, height: 30) {
                    // TODO: - go to tools
                }
                .padding(.top, 10)
            }
            .padding([.top, .bottom], 56)
            .padding([.leading, .trailing], 35)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct FindFavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        FindFavoriteToolsView()
    }
}
