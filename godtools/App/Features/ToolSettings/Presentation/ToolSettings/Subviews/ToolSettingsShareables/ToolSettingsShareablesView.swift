//
//  ToolSettingsShareablesView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsShareablesView: View {
    
    private let relatedContentSize: CGSize = CGSize(width: 112, height: 112)
    
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    init(viewModel: ToolSettingsViewModel, leadingInset: CGFloat, trailingInset: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
    }
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text(viewModel.shareablesTitle)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 19))
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: 0))
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                LazyHStack(alignment: .center, spacing: 10) {
                    
                    ForEach(viewModel.shareables) { (shareable: ShareableDomainModel) in
                        
                        ToolSettingsShareableItemView(
                            viewModel: viewModel.getShareableItemViewModel(shareable: shareable),
                            tappedClosure: {
                                viewModel.shareableTapped(shareable: shareable)
                            }
                        )
                    }
                }
            }
        }
    }
}
