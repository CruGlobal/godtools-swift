//
//  DownloadToolTranslationsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class DownloadToolTranslationsFlow: Flow {
    
    private let determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType
    private let getToolTranslationsUseCase: GetToolTranslationsUseCase
    private let didDownloadToolTranslations: ((_ result: Result<ToolTranslations, GetToolTranslationsError>) -> Void)
    
    private var downloadToolView: DownloadToolView?
    private var downloadToolModal: UIViewController?
    
    private weak var presentInFlow: Flow?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(presentInFlow: Flow, appDiContainer: AppDiContainer, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, didDownloadToolTranslations: @escaping ((_ result: Result<ToolTranslations, GetToolTranslationsError>) -> Void)) {
        
        self.presentInFlow = presentInFlow
        self.appDiContainer = appDiContainer
        self.navigationController = presentInFlow.navigationController
        self.determineToolTranslationsToDownload = determineToolTranslationsToDownload
        self.getToolTranslationsUseCase = appDiContainer.getToolTranslationsUseCase()
        self.didDownloadToolTranslations = didDownloadToolTranslations
           
        getToolTranslationsUseCase.getToolTranslations(determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: { [weak self] in
            
            self?.navigateToDownloadTool { [weak self] in
                
                self?.getToolTranslationsUseCase.cancel()
                self?.dismissDownloadTool()
            }
            
        }, downloadFinished: { [weak self] (result: Result<ToolTranslations, GetToolTranslationsError>) in
                        
            self?.didDownloadToolTranslations(result)
            
            self?.downloadToolView?.completeDownload(didCompleteDownload: { [weak self] in
                
                self?.dismissDownloadTool()
            })
        })
    }
    
    func navigate(step: FlowStep) {
        
    }
    
    private func navigateToDownloadTool(didCloseClosure: @escaping (() -> Void)) {
        
        guard downloadToolModal == nil else {
            return
        }
        
        let favoritedResourcesCache: FavoritedResourcesCache = appDiContainer.favoritedResourcesCache
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        let resource: ResourceModel? = determineToolTranslationsToDownload.getResource()
        
        let downloadMessage: String
        
        let resourceType: ResourceType? = resource?.resourceTypeEnum
        
        if resourceType == .article || resourceType == .tract, let resourceId = resource?.id {
            
            let isFavoritedResource: Bool = favoritedResourcesCache.isFavorited(resourceId: resourceId)
            
            downloadMessage = isFavoritedResource ? localizationServices.stringForMainBundle(key: "loading_favorited_tool") : localizationServices.stringForMainBundle(key: "loading_unfavorited_tool")
        }
        else if resourceType == .lesson {
            
            downloadMessage = localizationServices.stringForMainBundle(key: "loading_favorited_tool")
        }
        else {
            
            downloadMessage = localizationServices.stringForMainBundle(key: "loading_favorited_tool")
        }
        
        let viewModel = DownloadToolViewModel(
            downloadMessage: downloadMessage,
            didCloseClosure: didCloseClosure
        )
        
        let view = DownloadToolView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view, navBarColor: .white, navBarIsTranslucent: false)
        
        navigationController.present(modal, animated: true, completion: nil)
        
        downloadToolView = view
        downloadToolModal = modal
    }
    
    private func dismissDownloadTool() {
        
        guard let modal = downloadToolModal else {
            return
        }
        
        modal.dismiss(animated: true)
        
        downloadToolView = nil
        downloadToolModal = nil
    }
}
