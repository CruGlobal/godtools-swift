//
//  SocialCreateAccountStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct SocialCreateAccountStringsDomainModel {
    
    let title: String
    let subtitle: String
    let createWithAppleActionTitle: String
    let createWithFacebookActionTitle: String
    let createWithGoogleActionTitle: String
    
    static var emptyValue: SocialCreateAccountStringsDomainModel {
        return SocialCreateAccountStringsDomainModel(title: "", subtitle: "", createWithAppleActionTitle: "", createWithFacebookActionTitle: "", createWithGoogleActionTitle: "")
    }
}
