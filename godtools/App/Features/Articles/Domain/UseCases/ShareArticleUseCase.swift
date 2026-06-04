//
//  ShareArticleUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ShareArticleUseCase {
    
    private let articleRepository: ArticleAemRepository
    
    init(articleRepository: ArticleAemRepository) {
        
        self.articleRepository = articleRepository
    }
    
    func execute(articleId: String) -> ShareArticleDomainModel {
        
        let aemCacheObject: ArticleAemCacheObject? = articleRepository.getAemCacheObject(aemUri: articleId)
        
        guard let aemCacheObject = aemCacheObject else {
            return ShareArticleDomainModel.emptyValue
        }
        
        // shareUrlString
        var urlString: String = aemCacheObject.aemData.articleJcrContent?.canonical ?? ""
        while urlString.last == "/" {
            urlString.removeLast()
        }
        if urlString.isEmpty {
            urlString = "https://everystudent.com"
        }
        
        let shareUrlString: String = urlString.appending("?icid=gtshare")
        
        let shareMessage = shareUrlString
        
        return ShareArticleDomainModel(
            analyticsScreenName: aemCacheObject.aemData.articleJcrContent?.title ?? "GodTools",
            shareMessage: shareMessage
        )
    }
}
