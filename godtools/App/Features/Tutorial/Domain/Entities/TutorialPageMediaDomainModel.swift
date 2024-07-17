//
//  TutorialPageMediaDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum TutorialPageMediaDomainModel {
    
    case animation(animatedResource: AnimatedResource)
    case image(name: String)
    case noMedia
    case video(videoId: String)
}
