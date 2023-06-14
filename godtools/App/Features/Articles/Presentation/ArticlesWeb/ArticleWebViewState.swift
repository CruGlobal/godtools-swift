//
//  ArticleWebViewState.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum ArticleWebViewState {
    
    case errorMessage(title: String, message: String)
    case loadingArticle
    case viewingArticle
}
