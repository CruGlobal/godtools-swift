//
//  FavoritingToolBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritingToolBannerView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ColorPalette.banner.color
            
            Image("nav_item_close")
                .padding(.top, 14)
                .padding(.trailing, 18)
            
            HStack {
                Spacer()
                
                Text("Message")
                    .font(.system(size: 18))
                    .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.top, .bottom], 25)
                
                Spacer()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct FavoritingToolBannerView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritingToolBannerView()
            .frame(width: 400)
            .previewLayout(.sizeThatFits)
    }
}
