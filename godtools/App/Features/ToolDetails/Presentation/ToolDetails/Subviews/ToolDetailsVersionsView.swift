//
//  ToolDetailsVersionsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsView: View {
        
    private let geometry: GeometryProxy
    private let cardHorizontalInsets: CGFloat = 20
    private let cardSpacing: CGFloat = 15
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
    
    let toolVersionTappedClosure: (() -> Void)
       
    init(viewModel: ToolDetailsViewModel, geometry: GeometryProxy, toolVersionTappedClosure: @escaping (() -> Void)) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.toolVersionTappedClosure = toolVersionTappedClosure
    }
    
    var body: some View {
                
        VStack(alignment: .leading, spacing: 0) {
            
            ToolDetailsSectionDescriptionTextView(
                viewModel: viewModel,
                geometry: geometry,
                text: viewModel.versionsDescription
            )
            
            LazyVStack(alignment: .center, spacing: cardSpacing) {
                
                ForEach(viewModel.toolVersions) { toolVersion in
                             
                    ToolDetailsVersionsCardView(
                        viewModel: viewModel.toolVersionCardWillAppear(toolVersion: toolVersion),
                        width: geometry.size.width - (cardHorizontalInsets * 2)
                    )
                    .padding(EdgeInsets(top: 0, leading: cardHorizontalInsets, bottom: 0, trailing: cardHorizontalInsets))
                    .onTapGesture {
                        viewModel.toolVersionTapped(toolVersion: toolVersion)
                        toolVersionTappedClosure()
                    }
                }
            }
            .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
        }
    }
}
