//
//  TutorialPageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TutorialPageDomainModel {
    
    let title: String
    let message: String
    let media: TutorialPageMediaDomainModel
    
    init(title: String, message: String, videoId: String?, animatedResource: AnimatedResource?, imageName: String?) {
        
        self.title = title
        self.message = message
        
        if let videoId = videoId, !videoId.isEmpty {
            media = .video(videoId: videoId)
        }
        else if let animatedResource = animatedResource {
            media = .animation(animatedResource: animatedResource)
        }
        else if let imageName = imageName, !imageName.isEmpty {
            media = .image(name: imageName)
        }
        else {
            media = .noMedia
        }
    }
    
    func getVideoId() -> String? {
        
        switch media {
        
        case.video(let videoId):
            return videoId
        
        default:
            return nil
        }
    }
}
