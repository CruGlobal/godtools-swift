//
//  DownloadToolTranslationsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

class DownloadToolTranslationsFlow: Flow {
    
    private let determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType
    private let getToolTranslationsUseCase: GetToolTranslationsUseCase
    private let didDownloadToolTranslations: ((_ result: Result<ToolTranslationsDomainModel, URLResponseError>) -> Void)
    
    private var downloadToolView: DownloadToolView?
    private var downloadToolModal: UIViewController?
    private var getToolTranslationsManifestsCancellable: AnyCancellable?
    
    private weak var presentInFlow: Flow?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(presentInFlow: Flow, appDiContainer: AppDiContainer, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, didDownloadToolTranslations: @escaping ((_ result: Result<ToolTranslationsDomainModel, URLResponseError>) -> Void)) {
        
        self.presentInFlow = presentInFlow
        self.appDiContainer = appDiContainer
        self.navigationController = presentInFlow.navigationController
        self.determineToolTranslationsToDownload = determineToolTranslationsToDownload
        self.getToolTranslationsUseCase = appDiContainer.domainLayer.getToolTranslationsUseCase()
        self.didDownloadToolTranslations = didDownloadToolTranslations
        
        getToolTranslationsManifestsCancellable = getToolTranslationsUseCase.getToolTranslations(determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: { [weak self] in
            
            self?.navigateToDownloadTool(didCloseClosure: { [weak self] in
                self?.dismissDownloadTool()
            })
        })
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completed in
            
            switch completed {
            case .finished:
                break
            case .failure(let error):
                self?.didDownloadToolTranslations(.failure(error))
            }
            
        }, receiveValue: { [weak self] (toolTranslations: ToolTranslationsDomainModel) in
            
            if let downloadToolView = self?.downloadToolView {
                downloadToolView.completeDownloadProgress {
                    self?.dismissDownloadTool()
                    self?.didDownloadToolTranslations(.success(toolTranslations))
                }
            }
            else {
                self?.didDownloadToolTranslations(.success(toolTranslations))
            }
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

