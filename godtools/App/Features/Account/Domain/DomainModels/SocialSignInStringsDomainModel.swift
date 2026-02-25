//
//  SocialSignInStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct SocialSignInStringsDomainModel {
    
    let title: String
    let subtitle: String
    let signInWithAppleActionTitle: String
    let signInWithFacebookActionTitle: String
    let signInWithGoogleActionTitle: String
    
    static var emptyValue: SocialSignInStringsDomainModel {
        return SocialSignInStringsDomainModel(title: "", subtitle: "", signInWithAppleActionTitle: "", signInWithFacebookActionTitle: "", signInWithGoogleActionTitle: "")
    }
}
