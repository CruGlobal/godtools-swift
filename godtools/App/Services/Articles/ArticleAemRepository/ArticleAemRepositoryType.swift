//
//  ArticleAemRepositoryType.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ArticleAemRepositoryType {
    
    func getArticleArchiveUrl(filename: String) -> URL?
    func getArticleAem(aemUri: ArticleAemUri, cache: @escaping ((_ articleAem: ArticleAemModel) -> Void), downloadStarted: @escaping (() -> Void), downloadFinished: @escaping ((_ result: Result<ArticleAemModel, Error>) -> Void))
}
