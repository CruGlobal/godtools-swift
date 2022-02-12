//
//  TrainingTipViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class TrainingTipViewModel: TrainingTipViewModelType {
    
    private let tipModel: Tip
    private let rendererPageModel: MobileContentRendererPageModel
    private let viewedTrainingTipsService: ViewedTrainingTipsService
    
    private var viewType: TrainingTipViewType = .rounded
    
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    
    required init(tipModel: Tip, rendererPageModel: MobileContentRendererPageModel, viewType: TrainingTipViewType, translationsFileCache: TranslationsFileCache, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.tipModel = tipModel
        self.rendererPageModel = rendererPageModel
        self.viewType = viewType
        self.viewedTrainingTipsService = viewedTrainingTipsService
            
        let trainingTipViewed: Bool = getTrainingTipViewed()
        
        reloadTipIcon(
            tipModel: tipModel,
            viewType: viewType,
            trainingTipViewed: trainingTipViewed
        )
    }
    
    private var trainingTipId: String {
        return tipModel.id
    }
    
    private func getTrainingTipViewed() -> Bool {
        
        let viewedTrainingTip = ViewedTrainingTip(
            trainingTipId: trainingTipId,
            resourceId: rendererPageModel.resource.id,
            languageId: rendererPageModel.language.id
        )
        
        let trainingTipViewed: Bool = viewedTrainingTipsService.containsViewedTrainingTip(viewedTrainingTip: viewedTrainingTip)
        
        return trainingTipViewed
    }
    
    private func reloadTipIcon(tipModel: Tip, viewType: TrainingTipViewType, trainingTipViewed: Bool) {
        
        let backgroundImageName: String
        switch viewType {
        case .upArrow:
            backgroundImageName = trainingTipViewed ? "training_tip_red_arrow_up_bg" : "training_tip_arrow_up_bg"
        case .rounded:
            backgroundImageName = trainingTipViewed ? "training_tip_red_square_bg" : "training_tip_square_bg"
        }
        
        let imageName: String
        
        switch tipModel.type {
        case .ask:
            imageName = trainingTipViewed ? "training_tip_ask_filled_red" : "training_tip_ask"
        case .consider:
            imageName = trainingTipViewed ? "training_tip_consider_filled_red" : "training_tip_consider"
        case .prepare:
            imageName = trainingTipViewed ? "training_tip_prepare_filled_red" : "training_tip_prepare"
        case .quote:
            imageName = trainingTipViewed ? "training_tip_quote_filled_red" : "training_tip_quote"
        case .tip:
            imageName = trainingTipViewed ? "training_tip_tip_filled_red" : "training_tip_tip"
        default:
            imageName = ""
        }
        
        trainingTipBackgroundImage.accept(value: UIImage(named: backgroundImageName))
        trainingTipForegroundImage.accept(value: UIImage(named: imageName))
    }
    
    func setViewType(viewType: TrainingTipViewType) {
        
        self.viewType = viewType
        
        reloadTipIcon(
            tipModel: tipModel,
            viewType: viewType,
            trainingTipViewed: getTrainingTipViewed()
        )
    }
    
    func tipTapped() -> TrainingTipEvent? {
               
        reloadTipIcon(tipModel: tipModel, viewType: viewType, trainingTipViewed: true)
        
        return TrainingTipEvent(rendererPageModel: rendererPageModel, trainingTipId: trainingTipId, tipModel: tipModel)
    }
}
