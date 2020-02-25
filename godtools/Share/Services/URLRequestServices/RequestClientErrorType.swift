//
//  RequestClientErrorType.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol RequestClientErrorType: Codable {
    
    var title: String { get }
    var message: String { get }
}
