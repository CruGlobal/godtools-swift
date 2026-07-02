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
    
    func execute(articleId: String) -> ArticleDomainModel {
        
        let aemCacheObject: ArticleAemCacheObject? = articleRepository.getAemCacheObject(aemUri: articleId)
        
        guard let aemCacheObject = aemCacheObject else {
            return ArticleDomainModel(id: articleId, title: "", httpsUrl: nil, archiveUrl: nil, isShareable: false)
        }
        
        let canonical: String = aemCacheObject.aemData.articleJcrContent?.canonical ?? ""
                
        return ArticleDomainModel(
            id: articleId,
            title: aemCacheObject.aemData.articleJcrContent?.title ?? "",
            httpsUrl: getHttpsUrl(aemCacheObject: aemCacheObject),
            archiveUrl: getArchiveUrl(aemCacheObject: aemCacheObject),
            isShareable: !canonical.isEmpty
        )
    }
    
    private func getHttpsUrl(aemCacheObject: ArticleAemCacheObject) -> ArticleUrlDomainModel? {
        
        guard let webUrl = URL(string: aemCacheObject.aemData.webUrl) else {
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
}
