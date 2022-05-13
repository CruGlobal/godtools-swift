//
//  ToolSettingsRelatedContentView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsRelatedContentView: View {
    
    private let relatedContentSize: CGSize = CGSize(width: 112, height: 112)
    
    @ObservedObject var viewModel: ToolSettingsRelatedContentViewModel
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Related graphics")
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: 0))
            
            LazyHList<ToolSettingsRelatedContentItemView>(itemSize: relatedContentSize, itemSpacing: 10, contentInsets: EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset), showsScrollIndicator: false, numberOfItems: $viewModel.numberOfItems, viewForItem: { index in
                
                return ToolSettingsRelatedContentItemView()
            })
                .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: relatedContentSize.height, idealHeight: nil, maxHeight: relatedContentSize.height, alignment: .leading)

        }
    }
}

struct ToolSettingsRelatedContentView_Preview: PreviewProvider {
    static var previews: some View {
        
        let viewModel = ToolSettingsRelatedContentViewModel()
        
        ToolSettingsRelatedContentView(
            viewModel: viewModel,
            leadingInset: 20,
            trailingInset: 20
        )
    }
}
