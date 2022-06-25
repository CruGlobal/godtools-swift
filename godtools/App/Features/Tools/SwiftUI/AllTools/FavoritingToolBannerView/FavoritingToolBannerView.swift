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
        
        BannerView {
            
            Text(viewModel.message)
                .modifier(BannerTextStyle())
            
        } closeButtonTapHandler: {
            
            viewModel.closeTapped()
        }
    }
}

struct FavoritingToolBannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        FavoritingToolBannerView(viewModel: BaseFavoritingToolBannerViewModel(message: "This is a test message.  It's pretty long.  Let's see what happens when the lines need to wrap."))
            .frame(width: 375)
            .previewLayout(.sizeThatFits)
    }
}
