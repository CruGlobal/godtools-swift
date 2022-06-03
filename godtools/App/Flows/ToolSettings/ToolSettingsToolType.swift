//
//  ToolSettingsToolType.swift
//  godtools
//
//  Created by Levi Eggert on 5/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ToolSettingsToolType {
    
    func setRenderer(renderer: MobileContentRenderer)
    func setTrainingTipsEnabled(enabled: Bool)
}
