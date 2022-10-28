//
//  FollowUpModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FollowUpModelType {
    
    var id: String { get }
    var name: String { get }
    var email: String { get }
    var destinationId: Int { get }
    var languageId: Int { get }
}
