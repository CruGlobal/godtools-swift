//
//  ViewShareToolDomainModelObserver.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewShareToolDomainModelObserver: ObservableObject {
    
    private var getViewShareToolUseCase: ViewShareToolUseCase
    private var getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase? = nil
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published var viewShareToolDomainModel: ViewShareToolDomainModel?

    init(getViewShareToolUseCase: ViewShareToolUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, toolSettingsObserver: ToolSettingsObserver) {
        
        self.getViewShareToolUseCase = getViewShareToolUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                
                getViewShareToolUseCase.viewPublisher(
                    toolId: toolSettingsObserver.toolId,
                    toolLanguageId: toolSettingsObserver.languages.selectedLanguageId,
                    pageNumber: toolSettingsObserver.pageNumber,
                    appLanguage: appLanguage
                )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainModel in
                
                self?.viewShareToolDomainModel = domainModel
            }
            .store(in: &cancellables)
    }
    
    init(getViewShareToolUseCase: ViewShareToolUseCase, appLanguage: AppLanguageDomainModel, toolId: String, toolLanguageId: String, pageNumber: Int) {
        
        self.getViewShareToolUseCase = getViewShareToolUseCase
        self.appLanguage = appLanguage
        
        getViewShareToolUseCase.viewPublisher(
            toolId: toolId,
            toolLanguageId: toolLanguageId,
            pageNumber: pageNumber,
            appLanguage: appLanguage
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] domainModel in
            
            self?.viewShareToolDomainModel = domainModel
        }
        .store(in: &cancellables)
    }
}
