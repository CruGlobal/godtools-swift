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
        
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
   
    let imageToShare: UIImage
    
    private var cancellables = Set<AnyCancellable>()
    
    init(imageToShare: UIImage, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.imageToShare = imageToShare
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ShareShareableViewModel {
    
    func pageViewed() {
        
        incrementUserCounterUseCase.incrementUserCounter(for: .imageShared)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
}
