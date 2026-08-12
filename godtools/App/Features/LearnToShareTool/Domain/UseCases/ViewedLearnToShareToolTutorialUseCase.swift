//
//  ViewedLearnToShareToolTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ViewedLearnToShareToolTutorialUseCase: Sendable {
    
    private let toolTrainingTipsOnboardingViewsRepository: ToolTrainingTipsOnboardingViewsRepository
    private let getTranslatedToolName: GetTranslatedToolName
    
    init(
        toolTrainingTipsOnboardingViewsRepository: ToolTrainingTipsOnboardingViewsRepository,
        getTranslatedToolName: GetTranslatedToolName
    ) {
        
        self.toolTrainingTipsOnboardingViewsRepository = toolTrainingTipsOnboardingViewsRepository
        self.getTranslatedToolName = getTranslatedToolName
    }
    
    func execute(appLanguage: AppLanguageDomainModel, toolId: String) async {
        
        let toolName: String = getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: appLanguage)
        
        await toolTrainingTipsOnboardingViewsRepository.storeToolTrainingTipViewed(
            toolId: toolId,
            toolName: toolName
        )
    }
}
