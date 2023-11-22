//
//  GetToolShortcutLinksUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolShortcutLinksUseCase {
        
    private let getToolShortcutLinksRepositoryInterface: GetToolShortcutLinksRepositoryInterface
    
    init(getToolShortcutLinksRepositoryInterface: GetToolShortcutLinksRepositoryInterface) {
        
        self.getToolShortcutLinksRepositoryInterface = getToolShortcutLinksRepositoryInterface
    }
    
    func getLinksPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Never> {
        
        return getToolShortcutLinksRepositoryInterface
            .getLinksPublisher(appLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
