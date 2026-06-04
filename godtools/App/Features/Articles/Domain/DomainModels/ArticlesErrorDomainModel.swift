//
//  ArticlesErrorDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ArticlesErrorDomainModel: Sendable {
    
    let title: String
    let message: String
    let downloadActionTitle: String
    
    init(title: String, message: String, downloadActionTitle: String) {
        
        self.title = title
        self.message = message
        self.downloadActionTitle = downloadActionTitle
    }
}
