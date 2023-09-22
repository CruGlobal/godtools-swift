//
//  LanguageSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LanguageSettingsView: View {
    
    @ObservedObject private var viewModel: LanguageSettingsViewModel
                
    init(viewModel: LanguageSettingsViewModel) {
       
        self.viewModel = viewModel
    }
        
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                LanguageSettingsAppInterfaceLanguageView(
                    viewModel: viewModel,
                    geometry: geometry
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .modifier(FlipForAppLanguage())
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
            getAppLanguageUseCase: appDiContainer.domainLayer.getAppLanguageUseCase(),
            getInterfaceStringUseCase: appDiContainer.domainLayer.getInterfaceStringUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        LanguageSettingsView(viewModel: viewModel)
    }
}
