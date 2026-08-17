//
//  DownloadableLanguagesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class DownloadableLanguagesViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDownloadableLanguagesStringsUseCase: GetDownloadableLanguagesStringsUseCase
    private let getDownloadableLanguagesListUseCase: GetDownloadableLanguagesListUseCase
    private let getSearchBarStringsUseCase: GetSearchBarStringsUseCase
    private let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
        
    private var cancellables = Set<AnyCancellable>()
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var allDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    
    @Published private(set) var displayedDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    @Published private(set) var searchBarStrings = SearchBarStringsDomainModel.emptyValue
    @Published private(set) var strings = DownloadableLanguagesStringsDomainModel.emptyValue
    
    @Published var searchText: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getDownloadableLanguagesStringsUseCase: GetDownloadableLanguagesStringsUseCase,
        getDownloadableLanguagesListUseCase: GetDownloadableLanguagesListUseCase,
        getSearchBarStringsUseCase: GetSearchBarStringsUseCase,
        searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase,
        downloadToolLanguageUseCase: DownloadToolLanguageUseCase,
        removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDownloadableLanguagesStringsUseCase = getDownloadableLanguagesStringsUseCase
        self.getDownloadableLanguagesListUseCase = getDownloadableLanguagesListUseCase
        self.getSearchBarStringsUseCase = getSearchBarStringsUseCase
        self.searchLanguageInDownloadableLanguagesUseCase = searchLanguageInDownloadableLanguagesUseCase
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
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
        .map{ (searchText: String, downloadableLanguages: [DownloadableLanguageListItemDomainModel]) in
            return AnyPublisher() {
                await searchLanguageInDownloadableLanguagesUseCase
                    .execute(
                        searchText: searchText,
                        downloadableLanguages: downloadableLanguages
                    )
            }
        }
        .switchToLatest()
        .assign(to: &$displayedDownloadableLanguages)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {

        searchBarStrings = getSearchBarStringsUseCase
            .execute(appLanguage: appLanguage)

        strings = getDownloadableLanguagesStringsUseCase
            .execute(appLanguage: appLanguage)
    }
    
    func getDownloadableLanguageItemViewModel(downloadableLanguage: DownloadableLanguageListItemDomainModel) -> DownloadableLanguageItemViewModel {
        
        return DownloadableLanguageItemViewModel(
            stepEmitter: stepEmitter,
            downloadableLanguage: downloadableLanguage,
            downloadToolLanguageUseCase: downloadToolLanguageUseCase,
            removeDownloadedToolLanguageUseCase: removeDownloadedToolLanguageUseCase
        )
    }
}

// MARK: - Inputs

extension DownloadableLanguagesViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromDownloadedLanguages)
    }
}
