//
//  LessonListItemDomainModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

protocol LessonListItemDomainModelInterface {
    
    var availabilityInAppLanguage: ToolLanguageAvailabilityDomainModel { get }
    var bannerImageId: String { get }
    var name: String { get }
}
