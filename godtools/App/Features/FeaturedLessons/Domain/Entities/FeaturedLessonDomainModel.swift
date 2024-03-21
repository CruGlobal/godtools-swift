//
//  FeaturedLessonDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct FeaturedLessonDomainModel: LessonListItemDomainModelInterface {
        
    let analyticsToolName: String
    let availabilityInAppLanguage: ToolLanguageAvailabilityDomainModel
    let bannerImageId: String
    let dataModelId: String
    let name: String
}

extension FeaturedLessonDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
