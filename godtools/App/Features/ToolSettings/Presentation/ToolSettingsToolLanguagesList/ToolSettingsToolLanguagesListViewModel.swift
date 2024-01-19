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
    
    private static var setPrimaryLanguageCancellable: AnyCancellable?
    private static var setParallelLanguageCancellable: AnyCancellable?
    private static var deleteParallelLanguageCancellable: AnyCancellable?
    
    private let listType: ToolSettingsToolLanguagesListTypeDomainModel
    private let tool: ResourceModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolSettingsPrimaryLanguageUseCase: GetToolSettingsPrimaryLanguageUseCase
    private let getToolSettingsParallelLanguageUseCase: GetToolSettingsParallelLanguageUseCase
    private let viewToolSettingsToolLanguageListUseCase: ViewToolSettingsToolLanguagesListUseCase
    private let setToolSettingsPrimaryLanguageUseCase: SetToolSettingsPrimaryLanguageUseCase
    private let setToolSettingsParallelLanguageUseCase: SetToolSettingsParallelLanguageUseCase
    private let deleteToolSettingsParallelLanguageUseCase: DeleteToolSettingsParallelLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var primaryLanguage: ToolSettingsToolLanguageDomainModel?
    @Published private var parallelLanguage: ToolSettingsToolLanguageDomainModel?
    
    @Published var languages: [ToolSettingsToolLanguageDomainModel] = Array()
    @Published var selectedLanguage: ToolSettingsToolLanguageDomainModel?
    @Published var showsDeleteLanguageButton: Bool = false
    @Published var deleteLanguageActionTitle: String = ""
    
    init(flowDelegate: FlowDelegate, listType: ToolSettingsToolLanguagesListTypeDomainModel, tool: ResourceModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolSettingsPrimaryLanguageUseCase: GetToolSettingsPrimaryLanguageUseCase, getToolSettingsParallelLanguageUseCase: GetToolSettingsParallelLanguageUseCase, viewToolSettingsToolLanguageListUseCase: ViewToolSettingsToolLanguagesListUseCase, setToolSettingsPrimaryLanguageUseCase: SetToolSettingsPrimaryLanguageUseCase, setToolSettingsParallelLanguageUseCase: SetToolSettingsParallelLanguageUseCase, deleteToolSettingsParallelLanguageUseCase: DeleteToolSettingsParallelLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.listType = listType
        self.tool = tool
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolSettingsPrimaryLanguageUseCase = getToolSettingsPrimaryLanguageUseCase
        self.getToolSettingsParallelLanguageUseCase = getToolSettingsParallelLanguageUseCase
        self.viewToolSettingsToolLanguageListUseCase = viewToolSettingsToolLanguageListUseCase
        self.setToolSettingsPrimaryLanguageUseCase = setToolSettingsPrimaryLanguageUseCase
        self.setToolSettingsParallelLanguageUseCase = setToolSettingsParallelLanguageUseCase
        self.deleteToolSettingsParallelLanguageUseCase = deleteToolSettingsParallelLanguageUseCase
        
        showsDeleteLanguageButton = listType == .chooseParallelLanguage
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)

        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> in
                
                return getToolSettingsPrimaryLanguageUseCase
                    .getLanguagePublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .assign(to: &$primaryLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> in
                
                return getToolSettingsParallelLanguageUseCase
                    .getLanguagePublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .assign(to: &$parallelLanguage)
        
        Publishers.CombineLatest3(
            $appLanguage.eraseToAnyPublisher(),
            $primaryLanguage.eraseToAnyPublisher(),
            $parallelLanguage.eraseToAnyPublisher()
        )
        .flatMap({ (appLanguage: AppLanguageDomainModel, primaryLanguage: ToolSettingsToolLanguageDomainModel?, parallelLanguage: ToolSettingsToolLanguageDomainModel?) -> AnyPublisher<ViewToolSettingsToolLanguagesListDomainModel, Never> in
            
            return viewToolSettingsToolLanguageListUseCase
                .viewPublisher(
                    listType: listType,
                    primaryLanguage: primaryLanguage,
                    parallelLanguage: parallelLanguage,
                    tool: tool,
                    appLanguage: appLanguage
                )
                .eraseToAnyPublisher()
        })
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] (domainModel: ViewToolSettingsToolLanguagesListDomainModel) in
            
            self?.languages = domainModel.languages
            self?.deleteLanguageActionTitle = domainModel.interfaceStrings.deleteParallelLanguageActionTitle
            
            switch listType {
            case .choosePrimaryLanguage:
                self?.selectedLanguage = self?.primaryLanguage
            case .chooseParallelLanguage:
                self?.selectedLanguage = self?.parallelLanguage
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
            
            ToolSettingsToolLanguagesListViewModel.deleteParallelLanguageCancellable = deleteToolSettingsParallelLanguageUseCase
                .deletePublisher()
                .sink(receiveValue: { _ in
                    
                })
            
            flowDelegate?.navigate(step: .deleteParallelLanguageTappedFromToolSettingsToolLanguagesList)
        }
    }
    
    func languageTapped(language: ToolSettingsToolLanguageDomainModel) {
        
        selectedLanguage = language
        
        switch listType {
            
        case .choosePrimaryLanguage:
            
            ToolSettingsToolLanguagesListViewModel.setPrimaryLanguageCancellable = setToolSettingsPrimaryLanguageUseCase
                .setLanguagePublisher(languageId: language.dataModelId)
                .sink(receiveValue: { _ in
                    
                })
            
            flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettingsToolLanguagesList(language: language))
            
        case .chooseParallelLanguage:
            
            ToolSettingsToolLanguagesListViewModel.setParallelLanguageCancellable = setToolSettingsParallelLanguageUseCase
                .setLanguagePublisher(languageId: language.dataModelId)
                .sink(receiveValue: { _ in
                    
                })
            
            flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettingsToolLanguagesList(language: language))
        }
    }
}
