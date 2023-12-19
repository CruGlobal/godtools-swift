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
            
            LazyHList<ToolSettingsShareableItemView>(itemSize: relatedContentSize, itemSpacing: 10, contentInsets: EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset), showsScrollIndicator: false, numberOfItems: $viewModel.numberOfShareableItems, viewForItem: { index in
                
                let itemViewModel = viewModel.getShareableItemViewModel(index: index)
                let itemView = ToolSettingsShareableItemView(viewModel: itemViewModel)
                
                return itemView
                
            }, itemTapped: { index in
                
                viewModel.shareableTapped(index: index)
            })
                .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: relatedContentSize.height, idealHeight: nil, maxHeight: relatedContentSize.height, alignment: .leading)

        }
    }
}
