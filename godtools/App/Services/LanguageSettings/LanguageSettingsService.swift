//
//  LanguageSettingsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

@available(*, deprecated) // TODO: Deprecated in place of LanguageSettingsRepository. ~Levi
class LanguageSettingsService {
        
    private static let primaryLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    private static let parallelLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    
    private let languagesRepository: LanguagesRepository
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    required init(languagesRepository: LanguagesRepository, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                guard let weakSelf = self else {
                    return
                }
                
                let primaryLanguageDataModel: LanguageModel?
                
                if let primaryLanguage = primaryLanguage {
                    primaryLanguageDataModel = weakSelf.languagesRepository.getLanguage(id: primaryLanguage.dataModelId)
                }
                else {
                    primaryLanguageDataModel = nil
                }
                
                LanguageSettingsService.primaryLanguage.accept(value: primaryLanguageDataModel)
            }
            .store(in: &cancellables)
        
        getSettingsParallelLanguageUseCase.getParallelLanguage()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (parallelLanguage: LanguageDomainModel?) in
                
                guard let weakSelf = self else {
                    return
                }
                
                let parallelLanguageDataModel: LanguageModel?
                
                if let parallelLanguage = parallelLanguage {
                    parallelLanguageDataModel = weakSelf.languagesRepository.getLanguage(id: parallelLanguage.dataModelId)
                }
                else {
                    parallelLanguageDataModel = nil
                }
                
                LanguageSettingsService.parallelLanguage.accept(value: parallelLanguageDataModel)
            }
            .store(in: &cancellables)
    }
    
    var primaryLanguage: ObservableValue<LanguageModel?> {
        return LanguageSettingsService.primaryLanguage
    }
    
    var parallelLanguage: ObservableValue<LanguageModel?> {
        return LanguageSettingsService.parallelLanguage
    }
}
