//
//  ViewToolDetailsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolDetailsUseCase {
    
    private let getInterfaceStringsRepository: GetToolDetailsInterfaceStringsRepositoryInterface
    private let getToolDetailsRepository: GetToolDetailsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolDetailsInterfaceStringsRepositoryInterface, getToolDetailsRepository: GetToolDetailsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getToolDetailsRepository = getToolDetailsRepository
    }
    
    func viewPublisher(tool: ToolDomainModel, translateInToolLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolDetailsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInToolLanguage: translateInToolLanguage),
            getToolDetailsRepository.getDetailsPublisher(tool: tool, translateInToolLanguage: translateInToolLanguage)
        )
        .flatMap({ (interfaceStrings: ToolDetailsInterfaceStringsDomainModel, toolDetails: ToolDetailsDomainModel) -> AnyPublisher<ViewToolDetailsDomainModel, Never> in
            
            let domainModel = ViewToolDetailsDomainModel(
                interfaceStrings: interfaceStrings,
                toolDetails: toolDetails
            )
            
            return Just(domainModel)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
