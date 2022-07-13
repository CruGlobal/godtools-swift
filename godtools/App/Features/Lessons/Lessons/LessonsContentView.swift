//
//  LessonsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonsContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LessonsContentViewModel
    
    // MARK: - Constants
    
    private enum Sizes {
        static let paddingMultiplier: CGFloat = 15/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        GeometryReader { geo in
            let width = geo.size.width
            let leadingTrailingPadding = width * Sizes.paddingMultiplier
            
            BackwardCompatibleList(rootViewType: Self.self) {
                
                LessonsListView(viewModel: viewModel.lessonsListViewModel, width: width, leadingPadding: leadingTrailingPadding)
                    .listRowInsets(EdgeInsets())
                
            } refreshHandler: {
                // TODO
            }
        }
        
    }
}

struct LessonsContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = LessonsContentViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices
        )
        
        LessonsContentView(viewModel: viewModel)
    }
}
