//
//  ToolPageModalViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol ToolPageModalViewModelType {
    
    var backgroundColor: UIColor { get }
    var listeners: [EventId] { get }
    var dismissListeners: [EventId] { get }
}
