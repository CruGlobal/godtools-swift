//
//  LoadingArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

@MainActor
final class LoadingArticleViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let articleAemRepository: ArticleAemRepository
    private let appLanguage: AppLanguageDomainModel
    
    private var downloadArticleTask: Task<Void, Error>?
        
    let message: String
    
    init(stepEmitter: FlowStepEmitter, aemUri: String, appLanguage: AppLanguageDomainModel, articleAemRepository: ArticleAemRepository, localizationServices: LocalizationServicesInterface) {
        
        self.stepEmitter = stepEmitter
        self.articleAemRepository = articleAemRepository
        self.appLanguage = appLanguage
        self.message = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "Download in progress")
        
        downloadArticleTask = Task { [weak self] in
            
            let downloadError: Error?
            
            do {
                
                let download = try await articleAemRepository
                    .downloadAndCache(
                        aemUris: [aemUri],
                        downloadCachePolicy: .fetchFromCacheUpToNextHour,
                        requestPriority: .high
                    )
                
                if let error = download.errors.first {
                    downloadError = error
                }
                else {
                    downloadError = nil
                }
            }
            catch let error {
                
                downloadError = error
            }
            
            try await Task.sleep(for: .seconds(1))
            
            if let downloadError = downloadError {
                
                let errorTitle: String = localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.error.key
                )
                
                let errorMessage: String = DownloadArticlesErrorViewModel(appLanguage: appLanguage, localizationServices: localizationServices, error: downloadError).message
                
                let alertMessage = AlertMessage(title: errorTitle, message: errorMessage)
                
                stepEmitter.emit(step: AppFlowStep.didFailToDownloadArticleFromLoadingArticle(alertMessage: alertMessage))
            }
            else {
                
                stepEmitter.emit(step: AppFlowStep.didDownloadArticleFromLoadingArticle(aemUri: aemUri))
            }
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        downloadArticleTask?.cancel()
    }
}
