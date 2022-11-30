//
//  MobileContentLinkViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentLinkViewModelType: ClickableMobileContentViewModel {
    
    var backgroundColor: UIColor { get }
    var font: UIFont { get }
    var title: String? { get }
    var titleColor: UIColor { get }
    var linkEvents: [EventId] { get }
    var rendererState: State { get }
    
    func linkTapped()
}
