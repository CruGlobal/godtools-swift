//
//  RealmPrimaryType.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmPrimaryType: Object {
    
    var id: String { get set }
}
