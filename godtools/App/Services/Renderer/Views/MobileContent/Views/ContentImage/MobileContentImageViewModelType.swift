//
//  MobileContentImageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentImageViewModelType: ClickableMobileContentViewModel {
    
    var image: UIImage? { get }
    var imageEvents: [EventId] { get }
    var rendererState: State { get }
    var imageWidth: MobileContentViewWidth { get }
    
    func imageTapped()
}
