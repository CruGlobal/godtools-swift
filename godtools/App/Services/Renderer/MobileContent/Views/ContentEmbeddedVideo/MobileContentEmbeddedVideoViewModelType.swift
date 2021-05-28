//
//  MobileContentEmbeddedVideoViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentEmbeddedVideoViewModelType {
    
    var videoId: String { get }
    var youtubePlayerParameters: [String: Any] { get }
}
