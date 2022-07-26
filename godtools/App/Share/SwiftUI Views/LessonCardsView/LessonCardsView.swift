//
//  LessonCardsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LessonCardProvider
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        ForEach(viewModel.lessons) { lesson in
            
            LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: width - 2 * leadingPadding)
                .listRowInsets(EdgeInsets())
                .contentShape(Rectangle())
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], leadingPadding)
            
        }
    }
}

struct LessonCardsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FeaturedLessonCardsViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            delegate: nil
        )
        
        LessonCardsView(viewModel: viewModel, width: 375, leadingPadding: 0)
    }
}
