//
//  LessonListItemDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LessonListItemDomainModel: LessonListItemDomainModelInterface {
    
    let analyticsToolName: String
    let availabilityInAppLanguage: ToolLanguageAvailabilityDomainModel
    let bannerImageId: String
    let dataModelId: String
    let name: String
}

extension LessonListItemDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
