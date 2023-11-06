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
    
    func getTutorialPublisher(appLanguageChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<TutorialDomainModel, Never> {
        
        return appLanguageChangedPublisher
            .flatMap({ (appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<(TutorialInterfaceStringsDomainModel, [TutorialPageDomainModel]), Never> in
                
                return Publishers.CombineLatest(
                    self.getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage),
                    self.getTutorialRepositoryInterface.getTutorialPublisher(translateInLanguage: appLanguage)
                )
                .eraseToAnyPublisher()
            })
            .flatMap({ (interfaceStrings: TutorialInterfaceStringsDomainModel, pages: [TutorialPageDomainModel]) -> AnyPublisher<TutorialDomainModel, Never> in
                
                let tutorial = TutorialDomainModel(interfaceStrings: interfaceStrings, pages: pages)
                
                return Just(tutorial)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
