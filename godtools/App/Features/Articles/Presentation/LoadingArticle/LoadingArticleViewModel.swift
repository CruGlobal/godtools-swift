//
//  LoadingArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LoadingArticleViewModel: ObservableObject {
    
    private let articleAemRepository: ArticleAemRepository
    
    private var downloadArticleOperation: OperationQueue?
    
    private weak var flowDelegate: FlowDelegate?
    
    let message: String
    
    init(flowDelegate: FlowDelegate, aemUri: String, articleAemRepository: ArticleAemRepository, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.articleAemRepository = articleAemRepository
        self.message = localizationServices.stringForSystemElseEnglish(key: "Download in progress")
        
        downloadArticle(
            aemUri: aemUri,
            articleAemRepository: articleAemRepository,
            localizationServices: localizationServices
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        downloadArticleOperation?.cancelAllOperations()
    }
    
    private func downloadArticle(aemUri: String, articleAemRepository: ArticleAemRepository, localizationServices: LocalizationServices) {
        
        downloadArticleOperation = articleAemRepository.downloadAndCache(aemUris: [aemUri]) { [weak self] (result: ArticleAemRepositoryResult) in
             
            DispatchQueue.main.async { [weak self] in
                
                if let aemCacheObject = articleAemRepository.getAemCacheObject(aemUri: aemUri) {
                    
                    self?.flowDelegate?.navigate(step: .didDownloadArticleFromLoadingArticle(aemCacheObject: aemCacheObject))
                }
                else {
                    
                    let errorTitle: String = localizationServices.stringForSystemElseEnglish(key: "error")
                    let errorMessage: String
                    
                    if let downloadError = result.downloaderResult.downloadError {
                        errorMessage = DownloadArticlesErrorViewModel(localizationServices: localizationServices, error: downloadError).message
                    }
                    else {
                        errorMessage = localizationServices.stringForSystemElseEnglish(key: "download_error")
                    }
                    
                    let alertMessage = AlertMessage(title: errorTitle, message: errorMessage)
                    
                    self?.flowDelegate?.navigate(step: .didFailToDownloadArticleFromLoadingArticle(alertMessage: alertMessage))
                }
            }
        }
    }
}
