//
//  FacebookProfile+LoadProfile.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

extension LoadFacebookProfile {
    
    func getCurrentProfileElseLoad() async throws -> FacebookProfile? {
        
        if let currentProfile = LoadFacebookProfile.current {
            return currentProfile
        }
        
        let loadedProfile = try await LoadFacebookProfile().loadProfile()
        
        return loadedProfile
    }
}
