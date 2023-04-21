//
//  ArticleDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

// NOTE: This will most likely get paired with a use case once we can refactor the Articles feature to use SwiftUI/Combine and UseCases. ~Levi
struct ArticleDomainModel {
    
    let url: URL?
    let urlType: ArticleUrlType?
}
