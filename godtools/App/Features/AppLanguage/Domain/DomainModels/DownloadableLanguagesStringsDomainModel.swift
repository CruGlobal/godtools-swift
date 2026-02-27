//
//  DownloadableLanguagesStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadableLanguagesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: DownloadableLanguagesStringsDomainModel {
        return DownloadableLanguagesStringsDomainModel(navTitle: "")
    }
}
