//
//  ToolSettingsToolLanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolSettingsToolLanguagesListViewModel: ObservableObject {
    
    static private var storePrimaryLanguageCancellable: AnyCancellable?
    static private var storeParallelLanguageCancellable: AnyCancellable?
    
    private let listType: ToolSettingsToolLanguagesListType
    private let tool: ResourceModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolSettingsToolLanguageListUseCase: ViewToolSettingsToolLanguagesListUseCase
    private let storeToolSettingsPrimaryLanguageUseCase: StoreToolSettingsPrimaryLanguageUseCase
    private let storeToolSettingsParallelLanguageUseCase: StoreToolSettingsParallelLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var languages: [ToolSettingsToolLanguageDomainModel] = Array()
    
    init(flowDelegate: FlowDelegate, listType: ToolSettingsToolLanguagesListType, tool: ResourceModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolSettingsToolLanguageListUseCase: ViewToolSettingsToolLanguagesListUseCase, storeToolSettingsPrimaryLanguageUseCase: StoreToolSettingsPrimaryLanguageUseCase, storeToolSettingsParallelLanguageUseCase: StoreToolSettingsParallelLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.listType = listType
        self.tool = tool
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolSettingsToolLanguageListUseCase = viewToolSettingsToolLanguageListUseCase
        self.storeToolSettingsPrimaryLanguageUseCase = storeToolSettingsPrimaryLanguageUseCase
        self.storeToolSettingsParallelLanguageUseCase = storeToolSettingsParallelLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolSettingsToolLanguagesListDomainModel, Never> in
                
                return self.viewToolSettingsToolLanguageListUseCase
                    .viewPublisher(tool: tool, appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (domainModel: ViewToolSettingsToolLanguagesListDomainModel) in
                
                self?.languages = domainModel.languages
            })
            .store(in: &cancellables)
    }
    
    func getListItemViewModel(domainModel: ToolSettingsToolLanguageDomainModel) -> ToolSettingsToolLanguagesListItemViewModel {
        
        return ToolSettingsToolLanguagesListItemViewModel(
            domainModel: domainModel
        )
    }
}

// MARK: - Inputs

extension ToolSettingsToolLanguagesListViewModel {
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolSettingsToolLanguagesList)
    }
    
    func languageTapped(language: ToolSettingsToolLanguageDomainModel) {
        
        switch listType {
            
        case .choosePrimaryLanguage:
            
            ToolSettingsToolLanguagesListViewModel.storePrimaryLanguageCancellable = storeToolSettingsPrimaryLanguageUseCase
                .storeLanguagePublisher(language: language)
                .sink(receiveValue: { _ in
                    
                })
            
        case .chooseParallelLanguage:
            
            ToolSettingsToolLanguagesListViewModel.storeParallelLanguageCancellable = storeToolSettingsParallelLanguageUseCase
                .storeLanguagePublisher(language: language)
                .sink(receiveValue: { _ in
                    
                })
        }
    }
}
