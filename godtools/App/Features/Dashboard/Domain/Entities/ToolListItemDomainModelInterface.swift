//
//  ToolListItemDomainModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol ToolListItemDomainModelInterface {
    
    var interfaceStrings: ToolListItemInterfaceStringsDomainModel { get }
    var analyticsToolAbbreviation: String { get }
    var dataModelId: String { get }
    var bannerImageId: String { get }
    var name: String { get }
    var category: String { get }
    var isFavorited: Bool { get }
    var languageAvailability: ToolLanguageAvailabilityDomainModel { get }
}
