//
//  ToolTrainingTipImagesProvider.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingTipImagesProvider {
    
    func getArrowUpBackground() -> UIImage? {
        return UIImage(named: "training_tip_arrow_up_bg")
    }
    
    func getSquareBackground() -> UIImage? {
        return UIImage(named: "training_tip_square_bg")
    }
    
    func getTrainingTipImage(trainingTipType: TrainingTipType) -> UIImage? {
        
        return UIImage(named: getTrainingTipImageName(trainingTipType: trainingTipType))
    }
    
    private func getTrainingTipImageName(trainingTipType: TrainingTipType) -> String {
        
        switch trainingTipType {
            
        case .ask:
            return "training_tip_ask"
        case .consider:
            return "training_tip_consider"
        case .prepare:
            return "training_tip_prepare"
        case .quote:
            return "training_tip_quote"
        case .tip:
            return "training_tip_tip"
        }
    }
}
