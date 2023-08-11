//
//  FeaturedLessonCardsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FeaturedLessonCardsView: View {
        
    private let width: CGFloat
    private let leadingPadding: CGFloat
    
    @ObservedObject private var viewModel: FeaturedLessonCardsViewModel
    
    init(viewModel: FeaturedLessonCardsViewModel, width: CGFloat, leadingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.width = width
        self.leadingPadding = leadingPadding
    }
    
    var body: some View {
        
        Group {
            
            Text(viewModel.sectionTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, leadingPadding)
            
            ForEach(viewModel.lessons) { lesson in
                
                LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: width - 2 * leadingPadding)
                    .listRowInsets(EdgeInsets())
                    .contentShape(Rectangle())
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing], leadingPadding)
                
            }
        }
    }
}

struct FeaturedLessonCardsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FeaturedLessonCardsViewModel(
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            delegate: nil
        )
        
        FeaturedLessonCardsView(viewModel: viewModel, width: 350, leadingPadding: 20)
    }
}
