//
//  ShareArticleDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ShareArticleDomainModel: Sendable {
    
    let analyticsScreenName: String
    let shareMessage: String
    
    static var emptyValue: ShareArticleDomainModel {
        return ShareArticleDomainModel(analyticsScreenName: "", shareMessage: "")
    }
}
