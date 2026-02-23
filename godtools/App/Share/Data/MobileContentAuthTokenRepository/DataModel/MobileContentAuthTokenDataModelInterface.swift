//
//  MobileContentAuthTokenDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAuthTokenDataModelInterface {
    
    var expirationDate: Date? { get }
    var id: String { get }
    var userId: String { get }
}
