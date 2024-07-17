//
//  GetTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

class GetTutorialUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetTutorialInterfaceStringsRepositoryInterface
    private let getTutorialRepositoryInterface: GetTutorialRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetTutorialInterfaceStringsRepositoryInterface, getTutorialRepositoryInterface: GetTutorialRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
        self.getTutorialRepositoryInterface = getTutorialRepositoryInterface
    }
    
    func getTutorialPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<TutorialDomainModel, Never> {
        
        return Publishers.CombineLatest(
            self.getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage),
            self.getTutorialRepositoryInterface.getTutorialPublisher(translateInLanguage: appLanguage)
        )
        .flatMap({ (interfaceStrings: TutorialInterfaceStringsDomainModel, pages: [TutorialPageDomainModel]) -> AnyPublisher<TutorialDomainModel, Never> in
            
            let tutorial = TutorialDomainModel(interfaceStrings: interfaceStrings, pages: pages)
            
            return Just(tutorial)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
