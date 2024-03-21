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
    private let viewToolShortcutLinksUseCase: ViewToolShortcutLinksUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published var shortcutLinks: [ToolShortcutLinkDomainModel] = Array()
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolShortcutLinksUseCase: ViewToolShortcutLinksUseCase) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolShortcutLinksUseCase = viewToolShortcutLinksUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolShortcutLinksDomainModel, Never> in
                
                return viewToolShortcutLinksUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewToolShortcutLinksDomainModel) in
                
                self?.shortcutLinks = domainModel.shortcutLinks
            }
            .store(in: &cancellables)
    }
}
