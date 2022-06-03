//
//  ToolSettingsShareablesView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsShareablesView: View {
    
    private let relatedContentSize: CGSize = CGSize(width: 112, height: 112)
    
    @ObservedObject var viewModel: BaseToolSettingsShareablesViewModel
    
    let primaryTextColor: Color
    let leadingInset: CGFloat
    let trailingInset: CGFloat
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text(viewModel.title)
                .foregroundColor(primaryTextColor)
                .font(FontLibrary.sfProTextRegular.font(size: 19))
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: 0))
            
            LazyHList<ToolSettingsShareableItemView>(itemSize: relatedContentSize, itemSpacing: 10, contentInsets: EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset), showsScrollIndicator: false, numberOfItems: $viewModel.numberOfItems, viewForItem: { index in
                
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

struct ToolSettingsShareablesView_Preview: PreviewProvider {
    static var previews: some View {
        
        let viewModel = BaseToolSettingsShareablesViewModel()
        
        ToolSettingsShareablesView(
            viewModel: viewModel,
            primaryTextColor: Color.black,
            leadingInset: 20,
            trailingInset: 20
        )
    }
}
