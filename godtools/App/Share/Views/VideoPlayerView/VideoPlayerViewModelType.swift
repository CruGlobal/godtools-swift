//
//  VideoPlayerViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 11/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol VideoPlayerViewModelType {
    
    var youtubeVideoId: String { get }
    
    func closeButtonTapped()
    func videoEnded()
}
