//
//  LearnToShareToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LearnToShareToolCellViewModel: LearnToShareToolCellViewModelType {
    
    let assetContent: LearnToShareToolAssetContent
    let title: String
    let message: String
    
    required init(learnToShareToolItem: LearnToShareToolItem, animationCache: AnimationCache) {
        
        title = learnToShareToolItem.title
        message = learnToShareToolItem.message
        
        if let animationName = learnToShareToolItem.animationName, !animationName.isEmpty {
            
            let animatedViewModel: AnimatedViewModel = AnimatedViewModel(
                animationDataResource: .mainBundleJsonFile(filename: animationName),
                animationCache: animationCache,
                autoPlay: true,
                loop: true
            )
            
            assetContent = .animation(viewModel: animatedViewModel)
        }
        else if let imageName = learnToShareToolItem.imageName, !imageName.isEmpty, let image = UIImage(named: imageName) {
            
            assetContent = .image(image: image)
        }
        else {
            
            assetContent = .none
        }
    }
}
