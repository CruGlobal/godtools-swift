//
//  ToolDetailsVersionsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsView: View {
        
    private let cardHorizontalInsets: CGFloat = 20
    private let cardSpacing: CGFloat = 15
    
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    let geometry: GeometryProxy
    let textEdgeInsets: EdgeInsets
    let toolVersionTappedClosure: (() -> Void)
        
    var body: some View {
                
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.versionsMessage)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
                .padding(textEdgeInsets)
            
            ForEach(viewModel.toolVersions) { toolVersion in
                         
                Rectangle()
                    .frame(width: geometry.size.width, height: cardSpacing)
                    .foregroundColor(.clear)
                
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
    }
}
