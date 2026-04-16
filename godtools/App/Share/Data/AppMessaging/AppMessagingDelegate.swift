//
//  AppMessagingDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol AppMessagingDelegate: AnyObject {
    
    func actionTappedWithUrl(url: URL, didOpenUrl: Bool)
}
