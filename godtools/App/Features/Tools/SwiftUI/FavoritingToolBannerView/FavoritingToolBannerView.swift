//
//  FavoritingToolBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritingToolBannerView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: FavoritingToolBannerViewModel
    
    // MARK: - Body
    
    var body: some View {
        Group {
            
            if viewModel.hidesMessage.value {
                EmptyView()
                
            } else {
                
                ZStack(alignment: .topTrailing) {
                    ColorPalette.banner.color
                    
                    Image("nav_item_close")
                        .padding(.top, 14)
                        .padding(.trailing, 18)
                    
                    HStack {
                        Spacer()
                        
                        Text(viewModel.message)
                            .font(.system(size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .padding([.top, .bottom], 30)
                            .padding(.leading, 45)
                            .padding(.trailing, 55)
                        
                        Spacer()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .transition(.slide)
    }
}

struct FavoritingToolBannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        FavoritingToolBannerView(viewModel: MockFavoritingToolBannerViewModel(message: "This is a test message.  It's pretty long.  Let's see what happens when the lines need to wrap.", hidesMessage: false))
            .frame(width: 375)
            .previewLayout(.sizeThatFits)
    }
}
