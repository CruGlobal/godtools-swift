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
    
    required init(trainingTipId: String, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentEvents: MobileContentEvents) {
        
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
    }
    
    var tipImage: UIImage? {
        return nil
    }
    
    func tipTapped() {
        
        guard let trainingTipNode = tipNode else {
            return
        }
        
        let trainingTipEvent: TrainingTipEvent = TrainingTipEvent(trainingTipId: trainingTipId, tipNode: trainingTipNode)
        mobileContentEvents.trainingTipTapped(trainingTipEvent: trainingTipEvent)
    }
}
