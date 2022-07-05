//
//  ToolVersionDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolVersionDomainModel: Identifiable {
    
    let id: String
    let bannerImageId: String
    let name: String
    let description: String
    let numberOfLanguages: Int
    let numberOfLanguagesString: String
    let primaryLanguage: String?
    let primaryLanguageIsSupported: Bool
    let parallelLanguage: String?
    let parallelLanguageIsSupported: Bool
    let isDefaultVersion: Bool
}
