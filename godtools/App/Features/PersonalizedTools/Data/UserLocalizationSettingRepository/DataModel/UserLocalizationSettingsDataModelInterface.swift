//
//  UserLocalizationSettingsDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol UserLocalizationSettingsDataModelInterface {
    
    var id: String { get }
    var createdAt: Date { get }
    var selectedCountryIsoRegionCode: String { get }
}
