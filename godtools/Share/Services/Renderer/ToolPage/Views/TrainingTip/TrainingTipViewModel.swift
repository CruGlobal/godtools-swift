//
//  TrainingTipViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingTipViewModel: TrainingTipViewModelType {
    
    private let trainingTipId: String
    private let mobileContentEvents: MobileContentEvents
    private let tipNode: TipNode?
    
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    
    required init(trainingTipId: String, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentEvents: MobileContentEvents, viewType: TrainingTipViewType) {
        
        self.trainingTipId = trainingTipId
        self.mobileContentEvents = mobileContentEvents
        
        let manifestTip: MobileContentXmlManifestTip? = manifest.tips[trainingTipId]
        let manifestTipSrc: String = manifestTip?.src ?? ""
        let translationsFileCache: TranslationsFileCache = translationsFileCache
        let location: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: manifestTipSrc)
        
        switch translationsFileCache.getData(location: location) {
            
        case .success(let xmlData):
            
            if let tipXmlData = xmlData, let tipNode = mobileContentNodeParser.parse(xml: tipXmlData, delegate: nil) as? TipNode {
                self.tipNode = tipNode
            }
            else {
                // TODO: Report that tip xml couldn't be parsed. ~Levi
                self.tipNode = nil
            }
                    
        case .failure(let error):
            // TODO: Report error that tips xml couldn't be loaded. ~Levi
            self.tipNode = nil
        }
        
        if let tipNode = self.tipNode {
            reloadTipIcon(tipNode: tipNode, viewType: viewType)
        }
    }
    
    private func reloadTipIcon(tipNode: TipNode, viewType: TrainingTipViewType) {
        
        if let tipTypeValue = tipNode.tipType, let trainingTipType = TrainingTipType(rawValue: tipTypeValue) {
            
            let backgroundImageName: String
            switch viewType {
            case .upArrow:
                backgroundImageName = "training_tip_arrow_up_bg"
            case .rounded:
                backgroundImageName = "training_tip_square_bg"
            }
            trainingTipBackgroundImage.accept(value: UIImage(named: backgroundImageName))
            
            let imageName: String
            switch trainingTipType {
            case .ask:
                imageName = "training_tip_ask"
            case .consider:
                imageName = "training_tip_consider"
            case .prepare:
                imageName = "training_tip_prepare"
            case .quote:
                imageName = "training_tip_quote"
            case .tip:
                imageName = "training_tip_tip"
            }
            trainingTipForegroundImage.accept(value: UIImage(named: imageName))
        }
    }
    
    func tipTapped() {
        
        guard let trainingTipNode = tipNode else {
            return
        }
        
        let trainingTipEvent: TrainingTipEvent = TrainingTipEvent(trainingTipId: trainingTipId, tipNode: trainingTipNode)
        mobileContentEvents.trainingTipTapped(trainingTipEvent: trainingTipEvent)
    }
}
