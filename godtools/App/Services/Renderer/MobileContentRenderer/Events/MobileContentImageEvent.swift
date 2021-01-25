//
//  MobileContentImageEvent.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentImageEvent {
    
    let imageNode: ContentImageNode
    let tapGesture: UITapGestureRecognizer
    
    required init(imageNode: ContentImageNode, tapGesture: UITapGestureRecognizer) {
        
        self.imageNode = imageNode
        self.tapGesture = tapGesture
    }
}
