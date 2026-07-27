//
//  GetArticleUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetArticleUseCase {
    
    private let articleRepository: ArticleAemRepository
    
    init(articleRepository: ArticleAemRepository) {
        
        self.articleRepository = articleRepository
    }
    
    func execute(articleId: String) async throws -> ArticleDomainModel {
        
        let aemCacheObject: ArticleAemCacheObject? = try await articleRepository.getAemCacheObject(aemUri: articleId)
        
        guard let aemCacheObject = aemCacheObject else {
            
            return ArticleDomainModel(
                id: articleId,
                title: "",
                httpsUrl: nil,
                archiveUrl: nil,
                isShareable: false,
                errorMessage: "Failed to fetch article from database."
            )
        }
        
        let canonical: String = aemCacheObject.aemData.articleJcrContent?.canonical ?? ""
                
        return ArticleDomainModel(
            id: articleId,
            title: aemCacheObject.aemData.articleJcrContent?.title ?? "",
            httpsUrl: getHttpsUrl(aemCacheObject: aemCacheObject),
            archiveUrl: getArchiveUrl(aemCacheObject: aemCacheObject),
            isShareable: !canonical.isEmpty,
            errorMessage: getErrorMessage(aemCacheObject: aemCacheObject)
        )
    }
    
    private func getHttpsUrl(aemCacheObject: ArticleAemCacheObject) -> ArticleUrlDomainModel? {
        
        guard let webUrlString = aemCacheObject.aemData.webUrl, let webUrl = URL(string: webUrlString) else {
            return nil
        }
        
        return ArticleUrlDomainModel(url: webUrl, urlType: .https)
    }
    
    private func getArchiveUrl(aemCacheObject: ArticleAemCacheObject) -> ArticleUrlDomainModel? {
        
        guard let archiveUrl = aemCacheObject.webArchiveFileUrl else {
            return nil
        }
        
        return ArticleUrlDomainModel(url: archiveUrl, urlType: .archive)
    }
    
    private func getErrorMessage(aemCacheObject: ArticleAemCacheObject) -> String? {
        
        guard let errorMessage = aemCacheObject.aemData.errorMessage else {
            return nil
        }
        
        let message: String = "Download article failed with error: \(errorMessage)"
        
        if let httpStatusCode = aemCacheObject.aemData.httpStatusCode {
            
            return message + " and httpStatusCode: \(httpStatusCode)"
        }
        else if let errorCode = aemCacheObject.aemData.errorCode {
            
            return message + " and errorCode: \(errorCode)"
        }
        else {
            
            return message
        }
    }
}
