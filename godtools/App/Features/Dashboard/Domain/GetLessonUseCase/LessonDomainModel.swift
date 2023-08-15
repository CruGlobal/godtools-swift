//
//  LessonDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct LessonDomainModel {
    
    let analyticsToolName: String
    let bannerImageId: String
    let dataModelId: String
    let languageIds: [String]
    let languageAvailability: String
    let title: String
}

extension LessonDomainModel: Equatable {
    
}

extension LessonDomainModel: Identifiable {
    
    var id: String {
        dataModelId
    }
}

extension LessonDomainModel: LanguageSupportable {
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return languageIds.contains(languageId)
        }
        
        return false
    }
}
