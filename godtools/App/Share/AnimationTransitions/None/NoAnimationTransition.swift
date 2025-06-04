//
//  NoAnimationTransition.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

class NoAnimationTransition: FadeAnimationTransition {
        
    enum Transition {
        case transitionIn
        case transitionOut
    }
        
    init(transition: NoAnimationTransition.Transition, duration: TimeInterval = FadeAnimationTransition.defaultDuration) {
                
        let fade: FadeAnimationTransition.Fade
        
        switch transition {
        case .transitionIn:
            fade = .fadeIn
        case .transitionOut:
            fade = .fadeOut
        }
        
        
        super.init(fade: fade, duration: duration, fadeOutAlpha: 0.99, fadeInAlpha: 1)
    }
}
