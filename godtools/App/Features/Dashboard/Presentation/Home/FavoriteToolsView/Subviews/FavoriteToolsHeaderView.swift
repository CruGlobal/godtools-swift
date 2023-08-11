//
//  FavoriteToolsHeaderView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoriteToolsHeaderView: View {
        
    private let leadingPadding: CGFloat
    
    @ObservedObject private var viewModel: FavoriteToolsViewModel
    
    init(viewModel: FavoriteToolsViewModel, leadingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingPadding = leadingPadding
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text(viewModel.sectionTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, leadingPadding)
                .padding(.top, 24)
            
            Spacer()
            
            if viewModel.tools.isEmpty == false {
                
                Text(viewModel.viewAllButtonText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .background(Color.white)
                    .padding(.bottom, 2)
                    .frame(height: 30, alignment: .bottom)
                    .onTapGesture {
                        viewModel.viewAllButtonTapped()
                    }
            }
        }
        .padding(.trailing, 20)
    }
}
