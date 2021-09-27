//
//  MobileContentLinkViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentLinkViewModelType {
    
    var backgroundColor: UIColor { get }
    var font: UIFont { get }
    var title: String? { get }
    var titleColor: UIColor { get }
    var linkEvents: [MultiplatformEventId] { get }
    var rendererState: MobileContentMultiplatformState { get }
    
    func linkTapped()
}
