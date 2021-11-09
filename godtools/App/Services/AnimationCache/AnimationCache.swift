//
//  AnimationCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Lottie

class AnimationCache: AnimationCacheProvider {
    
    private let lottieAnimationCache: LRUAnimationCache = LRUAnimationCache()
    
    required init() {
        
    }
    
    func animation(forKey: String) -> Animation? {
        return lottieAnimationCache.animation(forKey: forKey)
    }
    
    func setAnimation(_ animation: Animation, forKey: String) {
        lottieAnimationCache.setAnimation(animation, forKey: forKey)
    }
    
    func clearCache() {
        lottieAnimationCache.clearCache()
    }
}
