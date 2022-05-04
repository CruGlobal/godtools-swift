//
//  AnimatedViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Lottie

class AnimatedViewModel: AnimatedViewModelType {
    
    let animationData: Animation?
    let autoPlay: Bool
    let loop: Bool
    
    required init(animationDataResource: AnimatedResource, autoPlay: Bool, loop: Bool) {
        
        switch animationDataResource {
        case .filepathJsonFile(let filepath):
            animationData = Animation.filepath(filepath, animationCache: nil)
        case .mainBundleJsonFile(let filename):
            animationData = Animation.named(filename, bundle: Bundle.main, subdirectory: nil, animationCache: nil)
        }
                
        self.autoPlay = autoPlay
        self.loop = loop
    }
    
    func getAssetSize() -> CGSize {
        return animationData?.size ?? .zero
    }
}
