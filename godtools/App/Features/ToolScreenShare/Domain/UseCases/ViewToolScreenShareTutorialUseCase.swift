//
//  ViewToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolScreenShareTutorialUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetToolScreenShareTutorialInterfaceStringsRepositoryInterface
    private let getTutorialRepositoryInterface: GetToolScreenShareTutorialRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetToolScreenShareTutorialInterfaceStringsRepositoryInterface, getTutorialRepositoryInterface: GetToolScreenShareTutorialRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
        self.getTutorialRepositoryInterface = getTutorialRepositoryInterface
    }
    
    func viewTutorialPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<ToolScreenShareTutorialDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<(ToolScreenShareInterfaceStringsDomainModel, [ToolScreenShareTutorialPageDomainModel]), Never> in
                
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
