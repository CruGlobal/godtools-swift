//
//  AlertMessageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AlertMessageViewModelType: AnyObject {
    
    var title: String? { get }
    var message: String? { get }
    var cancelTitle: String? { get }
    var acceptTitle: String { get }
    
    func cancelTapped()
    func acceptTapped()
}
