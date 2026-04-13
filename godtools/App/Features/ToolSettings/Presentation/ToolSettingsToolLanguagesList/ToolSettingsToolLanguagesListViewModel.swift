//
//  ToolSettingsToolLanguagesListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class ToolSettingsToolLanguagesListViewModel: ObservableObject {
        
    private let listType: ToolSettingsToolLanguagesListTypeDomainModel
    private let toolId: String
    private let toolSettingsObserver: ToolSettingsObserver
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolSettingsToolLanguagesListStringsUseCase: GetToolSettingsToolLanguagesListStringsUseCase
    private let getToolSettingsToolLanguagesListUseCase: GetToolSettingsToolLanguagesListUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings = ToolSettingsToolLanguagesListStringsDomainModel.emptyValue
    @Published private(set) var languages: [ToolSettingsToolLanguageDomainModel] = Array()
    @Published private(set) var selectedLanguageId: String?
    @Published private(set) var showsDeleteLanguageButton: Bool = false
    
    init(flowDelegate: FlowDelegate, listType: ToolSettingsToolLanguagesListTypeDomainModel, toolId: String, toolSettingsObserver: ToolSettingsObserver, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolSettingsToolLanguagesListStringsUseCase: GetToolSettingsToolLanguagesListStringsUseCase, getToolSettingsToolLanguagesListUseCase: GetToolSettingsToolLanguagesListUseCase) {
        
        self.flowDelegate = flowDelegate
        self.listType = listType
        self.toolId = toolId
        self.toolSettingsObserver = toolSettingsObserver
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolSettingsToolLanguagesListStringsUseCase = getToolSettingsToolLanguagesListStringsUseCase
        self.getToolSettingsToolLanguagesListUseCase = getToolSettingsToolLanguagesListUseCase
        
        showsDeleteLanguageButton = listType == .chooseParallelLanguage
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage.dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getToolSettingsToolLanguagesListStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ToolSettingsToolLanguagesListStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            toolSettingsObserver.$languages
        )
        .map { (appLanguage: AppLanguageDomainModel, languages: ToolSettingsLanguages) in
            
            getToolSettingsToolLanguagesListUseCase
                .execute(
                    listType: listType,
                    primaryLanguageId: languages.primaryLanguageId,
                    parallelLanguageId: languages.parallelLanguageId,
                    toolId: toolId,
                    appLanguage: appLanguage
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (languages: [ToolSettingsToolLanguageDomainModel]) in
            
            self?.languages = languages
            
            switch listType {
            case .choosePrimaryLanguage:
                self?.selectedLanguageId = self?.toolSettingsObserver.languages.primaryLanguageId
            case .chooseParallelLanguage:
                self?.selectedLanguageId = self?.toolSettingsObserver.languages.parallelLanguageId
            }
        })
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ToolSettingsToolLanguagesListViewModel {
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolSettingsToolLanguagesList)
    }
    
    func deleteLanguageTapped() {
        
        switch listType {
            
        case .choosePrimaryLanguage:
            break
            
        case .chooseParallelLanguage:
            
            let currentLanguages = toolSettingsObserver.languages
            let parallelIsSelected: Bool = currentLanguages.parallelLanguageId == currentLanguages.selectedLanguageId
            
            toolSettingsObserver.languages = ToolSettingsLanguages(
                primaryLanguageId: currentLanguages.primaryLanguageId,
                parallelLanguageId: nil,
                selectedLanguageId: parallelIsSelected ? currentLanguages.primaryLanguageId : currentLanguages.selectedLanguageId
            )

            flowDelegate?.navigate(step: .deleteParallelLanguageTappedFromToolSettingsToolLanguagesList)
        }
    }
    
    func languageTapped(languageId: String) {
        
        selectedLanguageId = languageId
        
        switch listType {
            
        case .choosePrimaryLanguage:
            
            let currentLanguages = toolSettingsObserver.languages
            let primaryIsSelected: Bool = currentLanguages.primaryLanguageId == currentLanguages.selectedLanguageId
            
            toolSettingsObserver.languages = ToolSettingsLanguages(
                primaryLanguageId: languageId,
                parallelLanguageId: currentLanguages.parallelLanguageId,
                selectedLanguageId: primaryIsSelected ? languageId : currentLanguages.selectedLanguageId
            )
            
            flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettingsToolLanguagesList)
            
        case .chooseParallelLanguage:
            
            let currentLanguages = toolSettingsObserver.languages
            let parallelIsSelected: Bool = currentLanguages.parallelLanguageId == currentLanguages.selectedLanguageId
            
            toolSettingsObserver.languages = ToolSettingsLanguages(
                primaryLanguageId: currentLanguages.primaryLanguageId,
                parallelLanguageId: languageId,
                selectedLanguageId: parallelIsSelected ? languageId : currentLanguages.selectedLanguageId
            )
                        
            flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettingsToolLanguagesList)
        }
    }
}
