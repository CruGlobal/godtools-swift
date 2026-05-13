//
//  LoadingArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LoadingArticleViewModel: ObservableObject {
    
    private let articleAemRepository: ArticleAemRepository
    private let appLanguage: AppLanguageDomainModel
    
    private var downloadArticleTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let message: String
    
    init(flowDelegate: FlowDelegate, aemUri: String, appLanguage: AppLanguageDomainModel, articleAemRepository: ArticleAemRepository, localizationServices: LocalizationServicesInterface) {
        
        self.flowDelegate = flowDelegate
        self.articleAemRepository = articleAemRepository
        self.appLanguage = appLanguage
        self.message = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "Download in progress")
        
        downloadArticleTask = Task { [weak self] in
            
            do {
                
                _ = try await articleAemRepository
                    .downloadAndCache(
                        aemUris: [aemUri],
                        downloadCachePolicy: .fetchFromCacheUpToNextHour,
                        requestPriority: .high
                    )
                
                if let aemCacheObject = articleAemRepository.getAemCacheObjectNonThrowing(aemUri: aemUri) {
                    
                    self?.flowDelegate?.navigate(step: .didDownloadArticleFromLoadingArticle(aemCacheObject: aemCacheObject))
                }
            }
            catch let error {
                
                let errorTitle: String = localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.error.key
                )
                
                let errorMessage: String = DownloadArticlesErrorViewModel(appLanguage: appLanguage, localizationServices: localizationServices, error: error).message
                
                let alertMessage = AlertMessage(title: errorTitle, message: errorMessage)
                
                self?.flowDelegate?.navigate(step: .didFailToDownloadArticleFromLoadingArticle(alertMessage: alertMessage))
            }
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        downloadArticleTask?.cancel()
    }
}
