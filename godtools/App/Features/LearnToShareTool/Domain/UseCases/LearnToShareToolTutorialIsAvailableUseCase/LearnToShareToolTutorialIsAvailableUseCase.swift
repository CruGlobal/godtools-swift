//
//  LearnToShareToolTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class LearnToShareToolTutorialIsAvailableUseCase: LearnToShareToolTutorialIsAvailableUseCaseInterface {
    
    private let toolTrainingTipsOnboardingViewsRepository: ToolTrainingTipsOnboardingViewsRepository
    private let getTranslatedToolName: GetTranslatedToolName
    
    init(
        toolTrainingTipsOnboardingViewsRepository: ToolTrainingTipsOnboardingViewsRepository,
        getTranslatedToolName: GetTranslatedToolName
    ) {
        
        self.toolTrainingTipsOnboardingViewsRepository = toolTrainingTipsOnboardingViewsRepository
        self.getTranslatedToolName = getTranslatedToolName
    }
    
    func execute(appLanguage: AppLanguageDomainModel, toolId: String) -> Bool {
        
        let toolName: String = getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: appLanguage)
        
        let numberOfViews: Int = toolTrainingTipsOnboardingViewsRepository.getNumberOfToolTrainingTipViews(toolId: toolId, toolName: toolName)
        
        let reachedMaximumViews: Bool = numberOfViews >= 3
        
        return !reachedMaximumViews
    }
}
