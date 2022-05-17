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
    let leadingPadding: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let spotlightCardWidthMultiplier: CGFloat = 200/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        if viewModel.spotlightTools.isEmpty == false {
            
            VStack(alignment: .leading, spacing: 5) {
                
                SpotlightTitleView(title: viewModel.spotlightTitle, subtitle: viewModel.spotlightSubtitle)
                .padding(.leading, leadingPadding)
                .padding(.top, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.spotlightTools) { tool in
                            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: width * Sizes.spotlightCardWidthMultiplier, isSpotlight: true)
                                .onTapGesture {
                                    viewModel.spotlightToolTapped(resource: tool)
                                }
                                .padding(.bottom, 12)
                                .padding(.top, 5)
                        }
                    }
                    .padding(.leading, leadingPadding)
                }
            }
        }
    }
}

// MARK: - Preview

struct ToolSpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        ToolSpotlightView(viewModel: MockToolSpotlightViewModel(), width: 375, leadingPadding: 20)
    }
}
