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
        
    private let listType: ToolSettingsToolLanguagesListTypeDomainModel
    private let toolId: String
    private let toolSettingsObserver: ToolSettingsObserver
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolSettingsToolLanguageListUseCase: ViewToolSettingsToolLanguagesListUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var languages: [ToolSettingsToolLanguageDomainModel] = Array()
    @Published var selectedLanguageId: String?
    @Published var showsDeleteLanguageButton: Bool = false
    @Published var deleteLanguageActionTitle: String = ""
    
    init(flowDelegate: FlowDelegate, listType: ToolSettingsToolLanguagesListTypeDomainModel, toolId: String, toolSettingsObserver: ToolSettingsObserver, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolSettingsToolLanguageListUseCase: ViewToolSettingsToolLanguagesListUseCase) {
        
        self.flowDelegate = flowDelegate
        self.listType = listType
        self.toolId = toolId
        self.toolSettingsObserver = toolSettingsObserver
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolSettingsToolLanguageListUseCase = viewToolSettingsToolLanguageListUseCase
        
        showsDeleteLanguageButton = listType == .chooseParallelLanguage
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            toolSettingsObserver.$languages
        )
        .map { (appLanguage: AppLanguageDomainModel, languages: ToolSettingsLanguages) in
            
            viewToolSettingsToolLanguageListUseCase
                .viewPublisher(
                    listType: listType,
                    primaryLanguageId: languages.primaryLanguageId,
                    parallelLanguageId: languages.parallelLanguageId,
                    toolId: toolId,
                    appLanguage: appLanguage
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] (domainModel: ViewToolSettingsToolLanguagesListDomainModel) in
            
            self?.languages = domainModel.languages
            self?.deleteLanguageActionTitle = domainModel.interfaceStrings.deleteParallelLanguageActionTitle
            
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
