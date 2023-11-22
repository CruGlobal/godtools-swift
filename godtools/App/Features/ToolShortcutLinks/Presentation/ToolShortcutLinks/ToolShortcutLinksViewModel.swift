//
//  ToolShortcutLinksViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolShortcutLinksViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolShortcutLinksUseCase: GetToolShortcutLinksUseCase
    
    @Published var shortcutLinks: [ToolShortcutLinkDomainModel] = Array()
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolShortcutLinksUseCase: GetToolShortcutLinksUseCase) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolShortcutLinksUseCase = getToolShortcutLinksUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Never> in
                
                return self.getToolShortcutLinksUseCase
                    .getLinksPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$shortcutLinks)
    }
}
