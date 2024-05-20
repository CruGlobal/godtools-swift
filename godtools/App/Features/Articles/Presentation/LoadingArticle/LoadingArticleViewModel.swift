//
//  LoadingArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

class LoadingArticleViewModel: ObservableObject {
    
    private let articleAemRepository: ArticleAemRepository
    private let appLanguage: AppLanguageDomainModel
    
    private var downloadArticleOperation: OperationQueue?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let message: String
    
    init(flowDelegate: FlowDelegate, aemUri: String, appLanguage: AppLanguageDomainModel, articleAemRepository: ArticleAemRepository, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.articleAemRepository = articleAemRepository
        self.appLanguage = appLanguage
        self.message = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "Download in progress")
        
        downloadArticle(
            appLanguage: appLanguage,
            aemUri: aemUri,
            articleAemRepository: articleAemRepository,
            localizationServices: localizationServices
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        downloadArticleOperation?.cancelAllOperations()
    }
    
    private func downloadArticle(appLanguage: AppLanguageDomainModel, aemUri: String, articleAemRepository: ArticleAemRepository, localizationServices: LocalizationServices) {
        
        downloadArticleOperation = articleAemRepository.downloadAndCache(aemUris: [aemUri]) { [weak self] (result: ArticleAemRepositoryResult) in
             
            DispatchQueue.main.async { [weak self] in
                
                if let aemCacheObject = articleAemRepository.getAemCacheObject(aemUri: aemUri) {
                    
                    self?.flowDelegate?.navigate(step: .didDownloadArticleFromLoadingArticle(aemCacheObject: aemCacheObject))
                }
                else {
                    
                    let errorTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.error.key)
                    let errorMessage: String
                    
                    if let downloadError = result.downloaderResult.downloadError {
                        errorMessage = DownloadArticlesErrorViewModel(appLanguage: appLanguage, localizationServices: localizationServices, error: downloadError).message
                    }
                    else {
                        errorMessage = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.downloadError.key)
                    }
                    
                    let alertMessage = AlertMessage(title: errorTitle, message: errorMessage)
                    
                    self?.flowDelegate?.navigate(step: .didFailToDownloadArticleFromLoadingArticle(alertMessage: alertMessage))
                }
            }
        }
    }
}
