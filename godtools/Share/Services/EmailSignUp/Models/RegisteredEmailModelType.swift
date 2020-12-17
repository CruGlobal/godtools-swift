//
//  RegisteredEmailModelType.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol RegisteredEmailModelType {
    
    var id: String { get }
    var email: String { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isRegisteredWithRemoteApi: Bool { get }
}
