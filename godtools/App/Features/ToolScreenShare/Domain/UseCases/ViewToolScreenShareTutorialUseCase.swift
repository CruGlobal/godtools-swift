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
    
    func viewTutorialPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolScreenShareTutorialDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage),
            getTutorialRepositoryInterface.getTutorialPublisher(translateInLanguage: appLanguage)
        )
        .map { (interfaceStrings: ToolScreenShareInterfaceStringsDomainModel, pages: [ToolScreenShareTutorialPageDomainModel]) in
            
            ToolScreenShareTutorialDomainModel(
                interfaceStrings: interfaceStrings,
                pages: pages
            )
        }
        .eraseToAnyPublisher()
    }
}
