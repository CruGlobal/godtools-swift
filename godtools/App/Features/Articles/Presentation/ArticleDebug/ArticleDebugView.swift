//
//  ArticleDebugView.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ArticleDebugView: View {
    
    private let horizontalPadding: CGFloat = 30
    
    @ObservedObject private var viewModel: ArticleDebugViewModel
    
    init(viewModel: ArticleDebugViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Article Debug View")
                    .foregroundColor(Color.black)
                    .font(FontLibrary.sfProTextSemibold.font(size: 19))
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 40, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
                
                Text("Article URL: \(viewModel.url)")
                    .foregroundColor(Color.black)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 30, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
                
                Text("Article URL Type: \(viewModel.urlType)")
                    .foregroundColor(Color.black)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 15, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
                
                Spacer()
                
                GTButton(
                    style: .blue,
                    title: "Copy Url",
                    font: FontLibrary.sfProTextSemibold.font(size: 15),
                    width: geometry.size.width - (horizontalPadding * 2),
                    height: 50,
                    tapped: {
                        viewModel.copyUrlTapped()
                    }
                )
                .padding(EdgeInsets(top: 0, leading: horizontalPadding, bottom: 40, trailing: 0))
            }
        }
        .navBar(
            title: nil,
            backTapped: nil,
            toolbarContent: {
                
                AppToolbarItem(
                    placement: AppToolbarItem.trailingPlacement,
                    viewType: .image(value: ImageCatalog.navClose.image),
                    color: ColorPalette.gtBlue.color,
                    accessibilityId: AccessibilityStrings.Button.close.id,
                    tappedClosure: {
                        
                        viewModel.closeTapped()
                    }
                )
            }
        )
    }
}
