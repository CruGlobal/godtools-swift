//
//  ViewedTrainingTipType.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated)
protocol ViewedTrainingTipType {
    
    var id: String { get }
    var trainingTipId: String { get }
    var resourceId: String { get }
    var languageId: String { get }
}
