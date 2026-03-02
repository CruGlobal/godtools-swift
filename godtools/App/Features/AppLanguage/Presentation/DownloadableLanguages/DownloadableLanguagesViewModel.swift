//
//  DownloadableLanguagesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class DownloadableLanguagesViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDownloadableLanguagesStringsUseCase: GetDownloadableLanguagesStringsUseCase
    private let getDownloadableLanguagesListUseCase: GetDownloadableLanguagesListUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private lazy var searchBarViewModel = SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var allDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    
    @Published private(set) var displayedDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    @Published private(set) var strings = DownloadableLanguagesStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDownloadableLanguagesStringsUseCase: GetDownloadableLanguagesStringsUseCase, getDownloadableLanguagesListUseCase: GetDownloadableLanguagesListUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDownloadableLanguagesStringsUseCase = getDownloadableLanguagesStringsUseCase
        self.getDownloadableLanguagesListUseCase = getDownloadableLanguagesListUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.searchLanguageInDownloadableLanguagesUseCase = searchLanguageInDownloadableLanguagesUseCase
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getDownloadableLanguagesStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: DownloadableLanguagesStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getDownloadableLanguagesListUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (downloadableLanguages: [DownloadableLanguageListItemDomainModel]) in
                
                self?.allDownloadableLanguages = downloadableLanguages
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $searchText,
            $allDownloadableLanguages.dropFirst()
        )
        .map({ (searchText: String, downloadableLanguages: [DownloadableLanguageListItemDomainModel]) in
            
            return searchLanguageInDownloadableLanguagesUseCase
                .execute(
                    searchText: searchText,
                    downloadableLanguages: downloadableLanguages
                )
                .map { downloadableLanguages in
                    return downloadableLanguages
                }
        })
        .switchToLatest()
        .assign(to: &$displayedDownloadableLanguages)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func getDownloadableLanguageItemViewModel(downloadableLanguage: DownloadableLanguageListItemDomainModel) -> DownloadableLanguageItemViewModel {
        
        return DownloadableLanguageItemViewModel(
            flowDelegate: flowDelegate!,
            downloadableLanguage: downloadableLanguage,
            downloadToolLanguageUseCase: downloadToolLanguageUseCase,
            removeDownloadedToolLanguageUseCase: removeDownloadedToolLanguageUseCase
        )
    }
}

// MARK: - Inputs

extension DownloadableLanguagesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromDownloadedLanguages)
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return searchBarViewModel
    }
}
