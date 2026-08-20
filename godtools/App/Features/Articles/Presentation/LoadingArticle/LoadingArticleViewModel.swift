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
    private let localizationServices: LocalizationServicesInterface
    private let getDownloadArticlesErrorMessage: GetDownloadArticlesErrorMessage
    private let appLanguage: AppLanguageDomainModel
            
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
        self.localizationServices = localizationServices
        self.getDownloadArticlesErrorMessage = getDownloadArticlesErrorMessage
        self.appLanguage = appLanguage

        let messageKey: String = LocalizableStringKeys.downloadInProgress.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                messageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        message = strings[messageKey] ?? ""

        download(aemUri: aemUri)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func download(aemUri: String) {
        
        Task { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            let downloadError: Error?
            
            do {
                
                let download: ArticleAemDownload = try await weakSelf.articleAemRepository
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
                
                let errorTitleKey: String = LocalizableStringKeys.error.key

                let strings: [String: String] = weakSelf.localizationServices.stringsForKeys(
                    keys: [
                        errorTitleKey
                    ],
                    fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: weakSelf.appLanguage),
                    shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
                )

                let errorTitle: String = strings[errorTitleKey] ?? ""
                
                let errorMessage: String = weakSelf.getDownloadArticlesErrorMessage.getErrorMessage(appLanguage: weakSelf.appLanguage, error: downloadError)
                                
                let alertMessage = AlertMessage(title: errorTitle, message: errorMessage)
                
                weakSelf.stepEmitter.emit(step: AppFlowStep.didFailToDownloadArticleFromLoadingArticle(alertMessage: alertMessage))
            }
            else {
                
                weakSelf.stepEmitter.emit(step: AppFlowStep.didDownloadArticleFromLoadingArticle(aemUri: aemUri))
            }
        }
    }
}
