//
//  ToolSpotlightView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSpotlightView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolSpotlightViewModel
    let width: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let spotlightCardWidthMultiplier: CGFloat = 200/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        if viewModel.spotlightTools.isEmpty == false {
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    
                    Text(viewModel.spotlightTitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 22))
                    Text(viewModel.spotlightSubtitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                }
                .padding(.leading, 20)
                .padding(.top, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.spotlightTools) { tool in
                            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: width * Sizes.spotlightCardWidthMultiplier, isSpotlight: true)
                        }
                    }
                    .padding(.leading, 12)
                }
            }
        }
        
    }
}

// MARK: - Preview

struct ToolSpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        ToolSpotlightView(viewModel: MockToolSpotlightViewModel(), width: 375)
    }
}
