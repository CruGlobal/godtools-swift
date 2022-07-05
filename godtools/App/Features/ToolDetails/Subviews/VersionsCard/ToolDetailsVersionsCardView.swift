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
        
    var body: some View {
        
        ZStack {
            
            Color.white
            
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
                    
                    CircleSelectorView(isSelected: viewModel.isSelected)
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
                        
                        HStack(alignment: .top, spacing: 0) {
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                
                                Text(viewModel.languages)
                                
                                if let primaryLanguageName = viewModel.primaryLanguageName {
                                    LanguageSupportedText(languageName: primaryLanguageName, isSupported: viewModel.primaryLanguageIsSupported)
                                }
                                
                                if let parallelLanguageName = viewModel.parallelLanguageName {
                                    LanguageSupportedText(languageName: parallelLanguageName, isSupported: viewModel.parallelLanguageIsSupported)
                                }
                            }
                            .foregroundColor(ColorPalette.gtLightGrey.color)
                            .font(FontLibrary.sfProTextRegular.font(size: 13))
                        }
                    }
                }
                .padding(EdgeInsets(top: 15, leading: 25, bottom: 25, trailing: 25))
            }
        }
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 1, y: 1)
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
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
            numberOfLanguages: 45,
            numberOfLanguagesString: "45 languages",
            primaryLanguage: "English",
            primaryLanguageIsSupported: true,
            parallelLanguage: "Spanish",
            parallelLanguageIsSupported: false,
            isDefaultVersion: false
        )
        
        let viewModel = ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            bannerImageRepository: appDiContainer.getResourceBannerImageRepository(),
            isSelected: false
        )
        
        ToolDetailsVersionsCardView(viewModel: viewModel)
    }
}
