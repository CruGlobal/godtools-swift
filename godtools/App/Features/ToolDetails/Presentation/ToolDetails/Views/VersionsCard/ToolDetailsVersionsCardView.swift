//
//  ToolDetailsVersionsCardView.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsCardView: View {
    
    private let bannerHeight: CGFloat = 87
    
    @ObservedObject var viewModel: ToolDetailsVersionsCardViewModel
    
    @State var isSelected: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            if let bannerImage = viewModel.bannerImage {
                bannerImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: bannerHeight)
                    .clipped()
            }
            else {
                Rectangle()
                    .fill(ColorPalette.gtLightestGrey.color)
                    .frame(height: bannerHeight)
            }
            
            HStack(alignment: .top, spacing: 0) {
                
                CircleSelectorView(isSelected: $isSelected)
                    .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0))
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: 16)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.name)
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextSemibold.font(size: 19))
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 5)
                    
                    Text(viewModel.description)
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 35)
                    
                    HStack(alignment: .top, spacing: 5) {
                        Spacer()
                        Text(viewModel.languages)
                        Text("|")
                        Text("French")
                        Text("|")
                        Text("English")
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                    .foregroundColor(ColorPalette.gtLightGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 13))
                }
            }
            .padding(EdgeInsets(top: 15, leading: 25, bottom: 0, trailing: 25))
        }
    }
}

struct ToolDetailsVersionsCardView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let toolVersion = ToolVersionDomainModel(
            id: "1",
            bannerImageId: "1",
            name: "Tool Name",
            description: "Tool description",
            languages: "45 languages",
            primaryLanguageSupported: "English",
            parallelLanguageSupported: "Spanish"
        )
        
        let viewModel = ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            bannerImageRepository: appDiContainer.getResourceBannerImageRepository()
        )
        
        ToolDetailsVersionsCardView(viewModel: viewModel)
    }
}
