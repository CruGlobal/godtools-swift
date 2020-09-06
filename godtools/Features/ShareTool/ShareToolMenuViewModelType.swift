//
//  ShareToolMenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ShareToolMenuViewModelType {
    
    var shareToolTitle: String { get }
    var remoteShareToolTitle: String { get }
    var cancelTitle: String { get }
    var hidesRemoteShareToolAction: Bool { get }
    
    func shareToolTapped()
    func remoteShareToolTapped()
}
