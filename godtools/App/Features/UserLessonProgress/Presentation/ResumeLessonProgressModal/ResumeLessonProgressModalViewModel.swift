//
//  ResumeLessonProgressModalViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
final class ResumeLessonProgressModalViewModel: ObservableObject {

    private let stepEmitter: FlowStepEmitter
    private let toolTranslations: ToolTranslationsDomainModel
    private let getResumeLessonProgressStringsUseCase: GetResumeLessonProgressStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = ResumeLessonProgressStringsDomainModel.emptyValue
    
    init(
        stepEmitter: FlowStepEmitter,
        toolTranslations: ToolTranslationsDomainModel,
        getResumeLessonProgressStringsUseCase: GetResumeLessonProgressStringsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.toolTranslations = toolTranslations
        self.getResumeLessonProgressStringsUseCase = getResumeLessonProgressStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getResumeLessonProgressStringsUseCase
            .execute(
                appLanguage: appLanguage
            )
    }

    // MARK: - Inputs
    
    func startOverButtonTapped() {
        stepEmitter.emit(step: AppFlowStep.startOverTappedFromResumeLessonModal(toolTranslations: toolTranslations))
    }
    
    func continueButtonTapped() {
        stepEmitter.emit(step: AppFlowStep.continueTappedFromResumeLessonModal(toolTranslations: toolTranslations))
    }
}
