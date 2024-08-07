//
//  LearnToShareToolItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class LearnToShareToolItemViewModel: ObservableObject {
    
    let assetContent: LearnToShareToolItemAssetContent
    let title: String
    let message: String
    
    init(learnToShareToolItem: LearnToShareToolItemDomainModel) {
        
        title = learnToShareToolItem.title
        message = learnToShareToolItem.message
        
        if let animationName = learnToShareToolItem.animationName, !animationName.isEmpty {
            
            let animatedViewModel: AnimatedViewModel = AnimatedViewModel(
                animationDataResource: .mainBundleJsonFile(filename: animationName),
                autoPlay: true,
                loop: true
            )
            
            assetContent = .animation(viewModel: animatedViewModel)
        }
        else if let imageName = learnToShareToolItem.imageName, !imageName.isEmpty {
            
            assetContent = .image(image: Image(imageName))
        }
        else {
            
            assetContent = .noAsset
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
