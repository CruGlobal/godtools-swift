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
    private var downloadableLanguages: [DownloadableLanguageListItemDomainModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published var searchText: String = ""
    @Published var downloadableLanguagesSearchResults: [DownloadableLanguageListItemDomainModel] = Array()
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
                self?.downloadableLanguagesSearchResults = downloadableLanguages
            }
            .store(in: &cancellables)
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
        
        // TODO: - This is for UI demo purposes only.  Remove once language download functionality is implemented.
                
//        switch downloadableLanguage.downloadStatus {
//        case .notDownloaded:
//            
//            updateDummyLanguage(with: .downloading(progress: 0))
//            
//            var progress: Double = 0
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
//                progress += 0.05
//                
//                self.updateDummyLanguage(with: .downloading(progress: progress))
//                
//                if progress >= 1 {
//                    timer.invalidate()
//                    self.updateDummyLanguage(with: .downloaded)
//                }
//            }
//            
//        case .downloading:
//            return
//            
//        case .downloaded:
//            updateDummyLanguage(with: .notDownloaded)
//        }
    }
}


