//
//  LanguageSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LanguageSettingsView: View {
    
    private let contentHorizontalInsets: CGFloat = 30
    
    @ObservedObject private var viewModel: LanguageSettingsViewModel
                
    init(viewModel: LanguageSettingsViewModel) {
       
        self.viewModel = viewModel
    }
        
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                LanguageSettingsAppInterfaceLanguageView(
                    viewModel: viewModel,
                    geometry: geometry,
                    contentHorizontalInsets: contentHorizontalInsets
                )
                .padding([.top], 30)
                
                ToolLanguagesAvailableOfflineView(
                    viewModel: viewModel,
                    geometry: geometry,
                    contentHorizontalInsets: contentHorizontalInsets
                )
                .padding([.top], 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

struct LanguageSettingsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = LanguageSettingsViewModel(
            flowDelegate: MockFlowDelegate(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewLanguageSettingsUseCase: appDiContainer.feature.appLanguage.domainLayer.getViewLanguageSettingsUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        LanguageSettingsView(viewModel: viewModel)
    }
}
