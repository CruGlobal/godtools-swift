//
//  EmailSignUpDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct EmailSignUpDataModel: Sendable {
    
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let isRegistered: Bool
}
