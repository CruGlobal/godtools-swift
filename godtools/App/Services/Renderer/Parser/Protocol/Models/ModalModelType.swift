//
//  ModalModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ModalModelType {
    
    var dismissListeners: [String] { get }
    var listeners: [String] { get }
}
