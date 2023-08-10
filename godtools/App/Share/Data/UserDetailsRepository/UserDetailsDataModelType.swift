//
//  UserDetailsDataModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

protocol UserDetailsDataModelType {
    
    var id: String { get }
    var createdAt: Date? { get }
    var familyName: String? { get }
    var givenName: String? { get }
    var name: String? { get }
    var ssoGuid: String? { get }
}
