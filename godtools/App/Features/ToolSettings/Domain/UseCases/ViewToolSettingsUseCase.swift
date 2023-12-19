//
//  ViewToolSettingsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolSettingsUseCase {
    
    private let getInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface
    private let getPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface
    private let getParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface, getPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface, getParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getPrimaryLanguageRepository = getPrimaryLanguageRepository
        self.getParallelLanguageRepository = getParallelLanguageRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolSettingsDomainModel, Never> {
        
        return Publishers.CombineLatest3(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getPrimaryLanguageRepository.getLanguagePublisher(translateInLanguage: appLanguage),
            getParallelLanguageRepository.getLanguagePublisher(translateInLanguage: appLanguage)
        )
        .map {
            
            let domainModel = ViewToolSettingsDomainModel(
                interfaceStrings: $0,
                primaryLanguage: $1,
                parallelLanguage: $2
            )
            
            return domainModel
        }
        .eraseToAnyPublisher()
    }
}
