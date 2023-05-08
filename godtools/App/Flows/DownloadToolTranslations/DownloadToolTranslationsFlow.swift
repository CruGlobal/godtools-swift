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
    private let getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase
    private let didDownloadToolTranslations: ((_ result: Result<ToolTranslationsDomainModel, URLResponseError>) -> Void)
    
    private var downloadToolView: DownloadToolView?
    private var downloadToolModal: UIViewController?
    private var cancellables = Set<AnyCancellable>()
    
    private weak var presentInFlow: Flow?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(presentInFlow: Flow, appDiContainer: AppDiContainer, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, didDownloadToolTranslations: @escaping ((_ result: Result<ToolTranslationsDomainModel, URLResponseError>) -> Void)) {
        
        self.presentInFlow = presentInFlow
        self.appDiContainer = appDiContainer
        self.navigationController = presentInFlow.navigationController
        self.determineToolTranslationsToDownload = determineToolTranslationsToDownload
        self.getToolTranslationsFilesUseCase = appDiContainer.domainLayer.getToolTranslationsFilesUseCase()
        self.didDownloadToolTranslations = didDownloadToolTranslations
        
        getToolTranslationsFilesUseCase.getToolTranslationsFilesPublisher(filter: .downloadManifestAndRelatedFilesForRenderer, determineToolTranslationsToDownload: determineToolTranslationsToDownload, downloadStarted: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.navigateToDownloadTool()
            }
        })
        .receiveOnMain()
        .sink(receiveCompletion: { [weak self] completed in
            
            switch completed {
            case .finished:
                break
            case .failure(let error):
                self?.dismissDownloadTool(completion: {
                    self?.didDownloadToolTranslations(.failure(error))
                })
            }
            
        }, receiveValue: { [weak self] (toolTranslations: ToolTranslationsDomainModel) in
            
            if let downloadToolView = self?.downloadToolView {
                downloadToolView.completeDownloadProgress {
                    self?.dismissDownloadTool(completion: nil)
                    self?.didDownloadToolTranslations(.success(toolTranslations))
                }
            }
            else {
                self?.didDownloadToolTranslations(.success(toolTranslations))
            }
        })
        .store(in: &cancellables)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        case .closeTappedFromDownloadToolProgress:
            dismissDownloadTool(completion: nil)
            
        default:
            break
        }
    }
    
    private func navigateToDownloadTool() {
        
        guard downloadToolModal == nil else {
            return
        }
        
        let favoritedResourcesRepository: FavoritedResourcesRepository = appDiContainer.dataLayer.getFavoritedResourcesRepository()
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        let resource: ResourceModel? = determineToolTranslationsToDownload.getResource()
        
        let downloadMessage: String
        
        let resourceType: ResourceType? = resource?.resourceTypeEnum
        
        if resourceType == .article || resourceType == .tract, let resourceId = resource?.id {
            
            let isFavoritedResource: Bool = favoritedResourcesRepository.getResourceIsFavorited(resourceId: resourceId)
            
            downloadMessage = isFavoritedResource ? localizationServices.stringForMainBundle(key: "loading_favorited_tool") : localizationServices.stringForMainBundle(key: "loading_unfavorited_tool")
        }
        else if resourceType == .lesson {
            
            downloadMessage = localizationServices.stringForMainBundle(key: "loading_favorited_tool")
        }
        else {
            
            downloadMessage = localizationServices.stringForMainBundle(key: "loading_favorited_tool")
        }
        
        let viewModel = DownloadToolViewModel(
            flowDelegate: self,
            downloadMessage: downloadMessage
        )
        
        let view = DownloadToolView(viewModel: viewModel)
        
        let modal = ModalNavigationController.defaultModal(rootView: view, statusBarStyle: .default)
        
        navigationController.present(modal, animated: true, completion: nil)
        
        downloadToolView = view
        downloadToolModal = modal
    }
    
    private func dismissDownloadTool(completion: (() -> Void)?) {
        
        guard let modal = downloadToolModal else {
            return
        }
        
        modal.dismiss(animated: true, completion: completion)
                
        downloadToolView = nil
        downloadToolModal = nil
    }
}

