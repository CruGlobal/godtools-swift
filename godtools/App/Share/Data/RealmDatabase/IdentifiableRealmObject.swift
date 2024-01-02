//
//  IdentifiableRealmObject.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

protocol IdentifiableRealmObject: Object {
    
    var id: String { get set }
}
