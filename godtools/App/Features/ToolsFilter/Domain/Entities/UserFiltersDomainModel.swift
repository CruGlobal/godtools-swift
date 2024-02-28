//
//  UserFiltersDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/16/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct UserFiltersDomainModel {
    
    let categoryFilterId: String? // TODO: - update this to use CategoryFilterDomainModel? as the type instead
    let languageFilter: LanguageFilterDomainModel?
}
