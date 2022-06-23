//
//  AllFavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllFavoriteToolsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllFavoriteToolsViewModel
    
    // MARK: - Constants
    
    private enum Sizes {
        static let toolsPaddingMultiplier: CGFloat = 15/375
    }
    
    // MARK: - Body
    var body: some View {
        
        GeometryReader { geo in
            let width = geo.size.width
            let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier
            
            BackwardCompatibleList {
                Text("Your favorite tools")
                    .font(FontLibrary.sfProTextRegular.font(size: 22))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .padding(.leading, leadingTrailingPadding)
                    .padding(.top, 40)
                
            } refreshHandler: {}
        }
    }
}

struct AllFavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        AllFavoriteToolsView(viewModel: AllFavoriteToolsViewModel())
    }
}
