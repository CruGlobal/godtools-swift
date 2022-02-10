//
//  MobileContentCardViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol MobileContentCardViewModelType {
    
    var events: [MultiplatformEventId] { get }
    var rendererState: MobileContentMultiplatformState { get }
}
