//
//  ShareShareableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

class ShareShareableViewModel {
        
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
   
    let imageToShare: UIImage
    
    private var cancellables = Set<AnyCancellable>()
    
    init(imageToShare: UIImage, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.imageToShare = imageToShare
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
    }
    
    func pageViewed() {
        
        incrementUserCounterUseCase.incrementUserCounter(for: .imageShared)?
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
