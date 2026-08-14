//
//  MobileContentErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

final class MobileContentErrorViewModel {
    
    let title: String
    let message: String
    let acceptTitle: String
    
    init(
        title: String,
        message: String,
        acceptTitle: String
    ) {
        
        self.title = title
        self.message = message
        self.acceptTitle = acceptTitle
    }
}
