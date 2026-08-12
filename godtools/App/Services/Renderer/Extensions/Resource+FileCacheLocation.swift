//
//  Resource+FileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

extension GodToolsShared.Resource {

    func toSHA256FileLocation() -> FileCacheLocation? {
        
        guard let localName = self.localName else {
            return nil
        }
        
        return FileCacheLocation(relativeUrlString: localName)
    }
}
