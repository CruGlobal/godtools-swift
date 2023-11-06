//
//  GetToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolScreenShareTutorialUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetToolScreenShareTutorialInterfaceStringsRepositoryInterface
    private let getTutorialRepositoryInterface: GetToolScreenShareTutorialRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetToolScreenShareTutorialInterfaceStringsRepositoryInterface, getTutorialRepositoryInterface: GetToolScreenShareTutorialRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
        self.getTutorialRepositoryInterface = getTutorialRepositoryInterface
    }
    
    func getTutorialPublisher(appLanguagePublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<ToolScreenShareTutorialDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<(ToolScreenShareInterfaceStringsDomainModel, [ToolScreenShareTutorialPageDomainModel]), Never> in
                
                return Publishers.CombineLatest(
                    self.getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage),
                    self.getTutorialRepositoryInterface.getTutorialPublisher(translateInLanguage: appLanguage)
                )
                .eraseToAnyPublisher()
            })
            .flatMap({ (interfaceStrings: ToolScreenShareInterfaceStringsDomainModel, pages: [ToolScreenShareTutorialPageDomainModel]) -> AnyPublisher<ToolScreenShareTutorialDomainModel, Never> in
                
                let tutorial = ToolScreenShareTutorialDomainModel(interfaceStrings: interfaceStrings, pages: pages)
                
                return Just(tutorial)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
