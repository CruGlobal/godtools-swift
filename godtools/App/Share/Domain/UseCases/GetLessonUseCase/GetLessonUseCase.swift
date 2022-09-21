//
//  GetLessonUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetLessonUseCase {
    
    func getLesson(resource: ResourceModel) -> LessonDomainModel {
        
        return LessonDomainModel(
            abbreviation: resource.abbreviation,
            bannerImageId: resource.attrBanner,
            dataModelId: resource.id,
            description: resource.resourceDescription,
            languageIds: resource.languageIds,
            name: resource.name
        )
    }
}
