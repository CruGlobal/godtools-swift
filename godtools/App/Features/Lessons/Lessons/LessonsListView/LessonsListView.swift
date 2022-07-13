//
//  LessonsListView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonsListView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LessonsListViewModel
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        Group {
            
            Text(viewModel.sectionTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, leadingPadding)
                .padding(.bottom, 7)
            
            LessonCardsView(viewModel: viewModel, width: width, leadingPadding: leadingPadding)
        }
    }
}

struct LessonsListView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = LessonsListViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            delegate: nil
        )
        
        LessonsListView(viewModel: viewModel, width: 350, leadingPadding: 20)
    }
}
