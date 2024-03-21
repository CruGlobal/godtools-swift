//
//  ViewToolShortcutLinksUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolShortcutLinksUseCase {
        
    private let getToolShortcutLinksRepositoryInterface: GetToolShortcutLinksRepositoryInterface
    
    init(getToolShortcutLinksRepositoryInterface: GetToolShortcutLinksRepositoryInterface) {
        
        self.getToolShortcutLinksRepositoryInterface = getToolShortcutLinksRepositoryInterface
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolShortcutLinksDomainModel, Never> {
        
        return getToolShortcutLinksRepositoryInterface
            .getLinksPublisher(appLanguage: appLanguage)
            .map {
                ViewToolShortcutLinksDomainModel(shortcutLinks: $0)
            }
            .eraseToAnyPublisher()
    }
}
