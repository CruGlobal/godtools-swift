//
//  DownloadableLanguagesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadableLanguagesViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewDownloadableLanguagesUseCase: ViewDownloadableLanguagesUseCase
    private let viewSearchBarUseCase: ViewSearchBarUseCase
    private let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private static var backgrounDownloadCancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var downloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    @Published private var activeDownloads: [BCP47LanguageIdentifier: LanguageDownloadStatusDomainModel] = [:]
    
    @Published var searchText: String = ""
    @Published var displayedDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewDownloadableLanguagesUseCase: ViewDownloadableLanguagesUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewDownloadableLanguagesUseCase = viewDownloadableLanguagesUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.searchLanguageInDownloadableLanguagesUseCase = searchLanguageInDownloadableLanguagesUseCase
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return viewDownloadableLanguagesUseCase.viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] domainModel in
                
                let interfaceStrings = domainModel.interfaceStrings
                let downloadableLanguages = domainModel.downloadableLanguages
                
                self?.navTitle = interfaceStrings.navTitle
                self?.downloadableLanguages = downloadableLanguages
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $searchText.eraseToAnyPublisher(),
            $downloadableLanguages.eraseToAnyPublisher(),
            $activeDownloads.eraseToAnyPublisher()
        )
        .flatMap({ searchText, downloadableLanguages, activeDownloads in
            
            return searchLanguageInDownloadableLanguagesUseCase.getSearchResultsPublisher(for: searchText, in: downloadableLanguages)
                .map { downloadableLanguages in
                    return (downloadableLanguages, activeDownloads)
                }
        })
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] downloadableLanguages, activeDownloads in
            
            self?.updateDisplayedLanguages(from: downloadableLanguages, activeDownloads: activeDownloads)
        })
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Private

extension DownloadableLanguagesViewModel {
    
    private func updateDisplayedLanguages(from downloadableLanguages: [DownloadableLanguageListItemDomainModel], activeDownloads: [BCP47LanguageIdentifier: LanguageDownloadStatusDomainModel]) {
        
        var updatedLanguages: [DownloadableLanguageListItemDomainModel] = Array()
        
        for downloadableLanguage in downloadableLanguages {
            
            if let activeDownloadStatus = activeDownloads[downloadableLanguage.languageId] {
                
                let downloadableLanguageWithProgressUpdate = downloadableLanguage.mapUpdatedDownloadStatus(downloadStatus: activeDownloadStatus)
                updatedLanguages.append(downloadableLanguageWithProgressUpdate)
                
            } else {
                
                updatedLanguages.append(downloadableLanguage)
            }
        }
        
        displayedDownloadableLanguages = updatedLanguages
    }
}

// MARK: - Inputs

extension DownloadableLanguagesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromDownloadedLanguages)
    }
    
    func getSearchBarViewModel() -> SearchBarViewModel {
        
        return SearchBarViewModel(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, viewSearchBarUseCase: viewSearchBarUseCase)
    }
    
    func downloadLanguage(_ downloadableLanguage: DownloadableLanguageListItemDomainModel) {
        
        let languageId = downloadableLanguage.languageId

        activeDownloads[languageId] = .downloading(progress: 0)
        
        downloadToolLanguageUseCase.downloadToolLanguage(languageId: downloadableLanguage.languageId, languageCode: downloadableLanguage.languageCode)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in
                
                switch completed {
                case .finished:
                    
                    self?.activeDownloads.removeValue(forKey: languageId)
                    
                case .failure(let error):
                    
                    // TODO: - what happens during a failure?
                    
                    self?.activeDownloads[languageId] = .notDownloaded
                    self?.flowDelegate?.navigate(step: .showLanguageDownloadErrorAlert(error: error))
                }
            }, receiveValue: { [weak self] progress in
                
                self?.activeDownloads[languageId] = .downloading(progress: progress)
            })
            .store(in: &DownloadableLanguagesViewModel.backgrounDownloadCancellables)
    }
    
    func removeDownloadedLanguage(_ downloadableLanguage: DownloadableLanguageListItemDomainModel) {
        
        removeDownloadedToolLanguageUseCase.removeDownloadedToolLanguage(downloadableLanguage.languageId)
            .sink { _ in
                
            }
            .store(in: &DownloadableLanguagesViewModel.backgrounDownloadCancellables)
    }
}


