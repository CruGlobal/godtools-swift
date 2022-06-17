//
//  ToolSettingsViewPreview.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

struct ToolSettingsViewPreview: PreviewProvider {
    
    static var previews: some View {
        
        ToolSettingsView(viewModel: ToolSettingsViewPreview.getToolSettingsViewModel())
    }
    
    static func getToolSettingsViewModel() -> ToolSettingsViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let languagesRepository: LanguagesRepository = appDiContainer.getLanguagesRepository()
        let englishLanguage: LanguageModel = languagesRepository.getLanguage(code: "en")!
                
        let viewModel = ToolSettingsViewModel(
            flowDelegate: MockFlowDelegate(),
            manifestResourcesCache: appDiContainer.getManifestResourcesCache(),
            localizationServices: appDiContainer.localizationServices,
            primaryLanguageSubject: CurrentValueSubject(englishLanguage),
            parallelLanguageSubject: CurrentValueSubject(nil),
            trainingTipsEnabled: false,
            shareables: []
        )
        
        return viewModel
    }
}
