//
//  MobileContentImageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentImageViewModelType {
    
    var image: UIImage? { get }
    var imageEvents: [MultiplatformEventId] { get }
    var rendererState: MobileContentMultiplatformState { get }
    var imageWidth: MobileContentViewWidth { get }
}
