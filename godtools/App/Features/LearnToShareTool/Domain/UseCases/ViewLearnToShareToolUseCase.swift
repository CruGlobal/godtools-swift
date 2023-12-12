//
//  ViewLearnToShareToolUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLearnToShareToolUseCase {
    
    private let getInterfaceStringsRepository: GetLearnToShareToolInterfaceStringsRepositoryInterface
    private let getTutorialItemsRepository: GetLearnToShareToolTutorialItemsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetLearnToShareToolInterfaceStringsRepositoryInterface, getTutorialItemsRepository: GetLearnToShareToolTutorialItemsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getTutorialItemsRepository = getTutorialItemsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLearnToShareToolDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getTutorialItemsRepository.getItemsPublisher(translateInLanguage: appLanguage)
        )
        .flatMap({ (interfaceStrings: LearnToShareToolInterfaceStringsDomainModel, tutorialItems: [LearnToShareToolItemDomainModel]) -> AnyPublisher<ViewLearnToShareToolDomainModel, Never> in
          
            let domainModel = ViewLearnToShareToolDomainModel(
                interfaceStrings: interfaceStrings,
                tutorialItems: tutorialItems
            )
            
            return Just(domainModel)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
