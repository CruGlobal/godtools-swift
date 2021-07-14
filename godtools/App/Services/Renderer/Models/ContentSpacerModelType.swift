//
//  ContentSpacerModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentSpacerModelType {
    
    var mode: String? { get }
    var height: String? { get }
    var spacerMode: MobileContentSpacerMode { get }
}
