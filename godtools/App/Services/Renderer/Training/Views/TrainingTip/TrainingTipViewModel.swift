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
    private let pageModel: MobileContentRendererPageModel
    private let viewedTrainingTipsService: ViewedTrainingTipsService
    
    private var tipNode: TipNode?
    private var viewType: TrainingTipViewType = .rounded
    
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    
    required init(trainingTipId: String, pageModel: MobileContentRendererPageModel, viewType: TrainingTipViewType, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.trainingTipId = trainingTipId
        self.pageModel = pageModel
        self.viewType = viewType
        self.viewedTrainingTipsService = viewedTrainingTipsService
                
        parseTrainingTip(trainingTipId: trainingTipId, manifest: pageModel.manifest, translationsFileCache: translationsFileCache, mobileContentNodeParser: mobileContentNodeParser) { [weak self] (result: Result<TipNode, Error>) in
            
            guard let viewModel = self else {
                return
            }
            
            switch result {
            
            case .success(let tipNode):
                
                let trainingTipViewed: Bool = viewModel.getTrainingTipViewed()
                
                viewModel.reloadTipIcon(
                    tipNode: tipNode,
                    viewType: viewModel.viewType,
                    trainingTipViewed: trainingTipViewed
                )
                
                viewModel.tipNode = tipNode
            
            case .failure(let error):
                break
            }
        }
    }
    
    private func getTrainingTipViewed() -> Bool {
        
        let viewedTrainingTip = ViewedTrainingTip(
            trainingTipId: trainingTipId,
            resourceId: pageModel.resource.id,
            languageId: pageModel.language.id
        )
        
        let trainingTipViewed: Bool = viewedTrainingTipsService.containsViewedTrainingTip(viewedTrainingTip: viewedTrainingTip)
        
        return trainingTipViewed
    }
    
    private func parseTrainingTip(trainingTipId: String, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, complete: @escaping ((_ result: Result<TipNode, Error>) -> Void)) {
        
        let manifestTip: MobileContentXmlManifestTip? = manifest.tips[trainingTipId]
        let manifestTipSrc: String = manifestTip?.src ?? ""
        let translationsFileCache: TranslationsFileCache = translationsFileCache
        let location: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: manifestTipSrc)
        
        DispatchQueue.global().async {
            
            let tipNode: TipNode?
            let error: Error?
            let defaultError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse tip from xml data."])
            
            switch translationsFileCache.getData(location: location) {
                
            case .success(let xmlData):
                
                if let tipXmlData = xmlData, let parsedTipNode = mobileContentNodeParser.parse(xml: tipXmlData, delegate: nil) as? TipNode {
                    tipNode = parsedTipNode
                    error = nil
                }
                else {
                    tipNode = nil
                    error = defaultError
                }
                        
            case .failure(let fileCacheError):
                tipNode = nil
                error = fileCacheError
            }
            
            DispatchQueue.main.async {
                
                if let tipNode = tipNode {
                    complete(.success(tipNode))
                }
                else {
                    complete(.failure(error ?? defaultError))
                }
            }
        }
    }
    
    private func reloadTipIcon(tipNode: TipNode, viewType: TrainingTipViewType, trainingTipViewed: Bool) {
        
        if let tipTypeValue = tipNode.tipType, let trainingTipType = TrainingTipType(rawValue: tipTypeValue) {
            
            let backgroundImageName: String
            switch viewType {
            case .upArrow:
                backgroundImageName = trainingTipViewed ? "training_tip_red_arrow_up_bg" : "training_tip_arrow_up_bg"
            case .rounded:
                backgroundImageName = trainingTipViewed ? "training_tip_red_square_bg" : "training_tip_square_bg"
            }
            
            let imageName: String
            switch trainingTipType {
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
            }
            
            trainingTipBackgroundImage.accept(value: UIImage(named: backgroundImageName))
            trainingTipForegroundImage.accept(value: UIImage(named: imageName))
        }
    }
    
    func setViewType(viewType: TrainingTipViewType) {
        
        self.viewType = viewType
        
        guard let tipNode = self.tipNode else {
            return
        }
        
        reloadTipIcon(
            tipNode: tipNode,
            viewType: viewType,
            trainingTipViewed: getTrainingTipViewed()
        )
    }
    
    func tipTapped() {
        
        guard let trainingTipNode = tipNode else {
            assertionFailure("tipNode is null, make sure tipNode is set.")
            return
        }
        
        //let trainingTipEvent: TrainingTipEvent = TrainingTipEvent(trainingTipId: trainingTipId, tipNode: trainingTipNode)
        
        // TODO: Implement.
        //mobileContentEvents.trainingTipTapped(trainingTipEvent: trainingTipEvent)
        
        if let tipNode = self.tipNode {
            reloadTipIcon(tipNode: tipNode, viewType: viewType, trainingTipViewed: true)
        }
    }
}
