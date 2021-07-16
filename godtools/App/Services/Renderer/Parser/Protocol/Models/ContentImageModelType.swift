//
//  ContentImageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentImageModelType {
    
    var events: [String] { get }
    var resource: String? { get }
    var restrictTo: String? { get }
}
