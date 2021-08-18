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
    private let rendererPageModel: MobileContentRendererPageModel
    private let viewedTrainingTipsService: ViewedTrainingTipsService
    
    private var tipModel: TipModelType?
    private var viewType: TrainingTipViewType = .rounded
    
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    
    required init(trainingTipId: String, rendererPageModel: MobileContentRendererPageModel, viewType: TrainingTipViewType, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.trainingTipId = trainingTipId
        self.rendererPageModel = rendererPageModel
        self.viewType = viewType
        self.viewedTrainingTipsService = viewedTrainingTipsService
                
        parseTrainingTip(trainingTipId: trainingTipId, manifest: rendererPageModel.manifest, translationsFileCache: translationsFileCache, mobileContentNodeParser: mobileContentNodeParser) { [weak self] (result: Result<TipNode, Error>) in
            
            guard let viewModel = self else {
                return
            }
            
            switch result {
            
            case .success(let tipNode):
                
                let trainingTipViewed: Bool = viewModel.getTrainingTipViewed()
                
                viewModel.reloadTipIcon(
                    tipModel: tipNode,
                    viewType: viewModel.viewType,
                    trainingTipViewed: trainingTipViewed
                )
                
                viewModel.tipModel = tipNode
            
            case .failure(let error):
                break
            }
        }
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
    
    private func parseTrainingTip(trainingTipId: String, manifest: MobileContentManifestType, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, complete: @escaping ((_ result: Result<TipNode, Error>) -> Void)) {
        
        let manifestTip: MobileContentManifestTipType? = manifest.tips[trainingTipId]
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
    
    private func reloadTipIcon(tipModel: TipModelType, viewType: TrainingTipViewType, trainingTipViewed: Bool) {
        
        let backgroundImageName: String
        switch viewType {
        case .upArrow:
            backgroundImageName = trainingTipViewed ? "training_tip_red_arrow_up_bg" : "training_tip_arrow_up_bg"
        case .rounded:
            backgroundImageName = trainingTipViewed ? "training_tip_red_square_bg" : "training_tip_square_bg"
        }
        
        let trainingTipType: MobileContentTrainingTipType = tipModel.tipType
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
        case .unknown:
            imageName = ""
        }
        
        trainingTipBackgroundImage.accept(value: UIImage(named: backgroundImageName))
        trainingTipForegroundImage.accept(value: UIImage(named: imageName))
    }
    
    func setViewType(viewType: TrainingTipViewType) {
        
        self.viewType = viewType
        
        guard let tipModel = self.tipModel else {
            return
        }
        
        reloadTipIcon(
            tipModel: tipModel,
            viewType: viewType,
            trainingTipViewed: getTrainingTipViewed()
        )
    }
    
    func tipTapped() -> TrainingTipEvent? {
        
        guard let tipModel = self.tipModel else {
            return nil
        }
                
        reloadTipIcon(tipModel: tipModel, viewType: viewType, trainingTipViewed: true)
        
        return TrainingTipEvent(rendererPageModel: rendererPageModel, trainingTipId: trainingTipId, tipModel: tipModel)
    }
}
