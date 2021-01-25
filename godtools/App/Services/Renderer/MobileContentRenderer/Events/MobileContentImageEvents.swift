//
//  MobileContentImageEvents.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentImageEvents {
    
    private let mobileContentEvents: MobileContentEvents
    
    private var imageEvents: [UIImageView: MobileContentImageEvent] = Dictionary()
    
    required init(mobileContentEvents: MobileContentEvents) {
        
        self.mobileContentEvents = mobileContentEvents
    }
    
    func removeAllImageEvents() {
        
        let images: [UIImageView] = Array(imageEvents.keys)
        
        for image in images {
            if let imageEvent = imageEvents[image] {
                image.removeGestureRecognizer(imageEvent.tapGesture)
                image.isUserInteractionEnabled = false
            }
        }
        
        imageEvents.removeAll()
    }
    
    func addImageEvent(image: UIImageView, imageNode: ContentImageNode) {
        
        guard imageEvents[image] == nil else {
            return
        }
        
        guard imageNode.events.count > 0 else {
            return
        }
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleImageTapped(tapGesture:))
        )
        
        image.addGestureRecognizer(tapGesture)
        image.isUserInteractionEnabled = true
        
        imageEvents[image] = MobileContentImageEvent(imageNode: imageNode, tapGesture: tapGesture)
    }
    
    @objc func handleImageTapped(tapGesture: UITapGestureRecognizer) {
        
        guard let image = tapGesture.view as? UIImageView else {
            return
        }
        
        guard let imageEvent = imageEvents[image] else {
            return
        }
        
        for event in imageEvent.imageNode.events {
            mobileContentEvents.eventImageTapped(eventImage: ImageEvent(event: event))
        }
    }
}
