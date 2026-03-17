//
//  ReviewShareShareableStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ReviewShareShareableStringsDomainModel: Sendable {
    
    let shareActionTitle: String
    
    static var emptyValue: ReviewShareShareableStringsDomainModel {
        return ReviewShareShareableStringsDomainModel(shareActionTitle: "")
    }
}
