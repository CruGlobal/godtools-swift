//
//  MobileContentFlowItemViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentFlowItemViewModelType {
    
    var visibilityState: ObservableValue<MobileContentViewVisibilityState> { get }
    var width: MobileContentViewWidth { get }
}
