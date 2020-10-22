//
//  TrainingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingViewModel: TrainingViewModelType {
    
    private var page: Int = 0
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let icon: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 4)
    
    required init() {
        
        setPage(page: 2)
    }
    
    private func setPage(page: Int) {
        
        self.page = page

        if numberOfTipPages.value > 0 {
            let trainingProgress: CGFloat = CGFloat(page) / CGFloat(numberOfTipPages.value)
            progress.accept(value: AnimatableValue(value: trainingProgress, animated: true))
        }
    }
    
    func overlayTapped() {
        
    }
    
    func closeTapped() {
        
    }
    
    func continueTapped() {
        
    }
}
