//
//  AlertMessageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AlertMessageViewModelType: class {
    
    var title: String { get }
    var message: String { get }
    var acceptActionTitle: String { get }
    
    func acceptTapped()
}
