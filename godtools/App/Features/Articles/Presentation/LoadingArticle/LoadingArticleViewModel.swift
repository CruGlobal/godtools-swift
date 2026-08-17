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
        
    @Published private(set) var message: String = ""

    init(
        stepEmitter: FlowStepEmitter,
        aemUri: String,
        appLanguage: AppLanguageDomainModel,
        articleAemRepository: ArticleAemRepository,
        localizationServices: LocalizationServicesInterface,
        getDownloadArticlesErrorMessage: GetDownloadArticlesErrorMessage
    ) {
        
        self.stepEmitter = stepEmitter
        self.articleAemRepository = articleAemRepository
        self.appLanguage = appLanguage

        message = localizationServices.stringForLocaleElseEnglishElseKey(
            localeIdentifier: appLanguage,
            key: LocalizableStringKeys.downloadInProgress.key
        )

        downloadArticleTask = Task {
            
            let downloadError: Error?
            
            do {
                
                let download: ArticleAemDownload = try await articleAemRepository
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
                
                let errorTitle: String = localizationServices.stringForLocaleElseEnglishElseKey(
                    localeIdentifier: appLanguage,
                    key: LocalizableStringKeys.error.key
                )
                
                let errorMessage: String = getDownloadArticlesErrorMessage.getErrorMessage(appLanguage: appLanguage, error: downloadError)
                                
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
