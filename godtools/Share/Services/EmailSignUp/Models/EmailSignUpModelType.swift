//
//  EmailSignUpModelType.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol EmailSignUpModelType {
    
    var email: String { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isRegistered: Bool { get }
}
