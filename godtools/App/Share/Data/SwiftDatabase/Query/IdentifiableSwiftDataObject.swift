//
//  IdentifiableSwiftDataObject.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
public protocol IdentifiableSwiftDataObject: PersistentModel {
    
    var id: String { get set }
}

@available(iOS 17.4, *)
extension IdentifiableSwiftDataObject {
    
    // TODO: Can remove this method once supporting min iOS 18 and up in place of Schema.entityName(for: ~Levi
    public static var entityName: String {
        return String(describing: String(describing: self))
    }
}
