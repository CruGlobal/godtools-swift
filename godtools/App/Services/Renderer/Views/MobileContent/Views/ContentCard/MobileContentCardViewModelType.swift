//
//  MobileContentCardViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentCardViewModelType: ClickableMobileContentViewModel {
    
    var events: [EventId] { get }
    var rendererState: State { get }
    
    func cardTapped()
}
