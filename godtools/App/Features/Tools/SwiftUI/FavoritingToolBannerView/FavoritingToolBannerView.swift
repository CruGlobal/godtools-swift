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
    
    @ObservedObject var viewModel: BaseFavoritingToolBannerViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ColorPalette.banner.color
            
            HStack {
                Spacer()
                
                Text(viewModel.message)
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .padding([.top, .bottom], 30)
                    .padding([.leading, .trailing], 45)
                
                Spacer()
            }
            
            Image(ImageCatalog.navClose.name)
                .padding(.trailing, 4)
                .frame(width: 44, height: 44)
                .onTapGesture {
                    withAnimation {
                        viewModel.closeTapped()
                    }
                }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct FavoritingToolBannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        FavoritingToolBannerView(viewModel: BaseFavoritingToolBannerViewModel(message: "This is a test message.  It's pretty long.  Let's see what happens when the lines need to wrap."))
            .frame(width: 375)
            .previewLayout(.sizeThatFits)
    }
}
