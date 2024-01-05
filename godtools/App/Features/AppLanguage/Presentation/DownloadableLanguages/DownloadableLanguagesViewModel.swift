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
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private static var backgrounDownloadCancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published var searchText: String = ""
    @Published var downloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    @Published var downloadableLanguagesSearchResults: [DownloadableLanguageListItemDomainModel] = Array()
    @Published var activeDownloads: [BCP47LanguageIdentifier: LanguageDownloadStatusDomainModel] = [:]
    @Published var navTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewDownloadableLanguagesUseCase: ViewDownloadableLanguagesUseCase, viewSearchBarUseCase: ViewSearchBarUseCase, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewDownloadableLanguagesUseCase = viewDownloadableLanguagesUseCase
        self.viewSearchBarUseCase = viewSearchBarUseCase
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return self.viewDownloadableLanguagesUseCase.viewPublisher(appLanguage: appLanguage)
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
        
        Publishers.CombineLatest(
            $downloadableLanguages.eraseToAnyPublisher(),
            $activeDownloads.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] downloadableLanguages, activeDownloads in
            
            self?.createResults(from: downloadableLanguages, activeDownloads: activeDownloads)
        })
        .store(in: &cancellables)
    }
    
    private func createResults(from downloadableLanguages: [DownloadableLanguageListItemDomainModel], activeDownloads: [BCP47LanguageIdentifier: LanguageDownloadStatusDomainModel]) {
        
        var results: [DownloadableLanguageListItemDomainModel] = Array()
        
        for downloadableLanguage in downloadableLanguages {
            
            if let activeDownloadStatus = activeDownloads[downloadableLanguage.languageId] {
                
                let downloadableLanguageWithProgressUpdate = downloadableLanguage.mapUpdatedDownloadStatus(downloadStatus: activeDownloadStatus)
                results.append(downloadableLanguageWithProgressUpdate)
            } else {
                
                
                results.append(downloadableLanguage)
            }
            
        }
        
        downloadableLanguagesSearchResults = results
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
    
    func downloadableLanguageTapped(downloadableLanguage: DownloadableLanguageListItemDomainModel) {
        
        let languageId = downloadableLanguage.languageId
        
        switch downloadableLanguage.downloadStatus {
            
        case .notDownloaded:
            
            activeDownloads[languageId] = .downloading(progress: 0)
            
            downloadToolLanguageUseCase.downloadToolLanguage(downloadableLanguage.languageCode)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completed in
                    switch completed {
                    case .finished:
                        
                        self?.activeDownloads.removeValue(forKey: languageId)
                        
                    case .failure(let error):
                        
                        // TODO: - what happens during a failure?
                        self?.activeDownloads[languageId] = .notDownloaded
                    }
                }, receiveValue: { [weak self] progress in
                    
                    self?.activeDownloads[languageId] = .downloading(progress: progress)
                })
                .store(in: &DownloadableLanguagesViewModel.backgrounDownloadCancellables)
            
        case .downloaded:
            
            removeDownloadedToolLanguageUseCase.removeDownloadedToolLanguage(downloadableLanguage.languageId)
                .sink { _ in
                    
                }
                .store(in: &DownloadableLanguagesViewModel.backgrounDownloadCancellables)
            
        case .downloading:
            
            break
        }
    }
}


