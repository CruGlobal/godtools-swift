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
        
    private let determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface
    private let getToolTranslationsFilesUseCase: GetToolTranslationsFilesUseCase
    private let didDownloadToolTranslations: ((_ result: Result<ToolTranslationsDomainModel, Error>) -> Void)
    
    private var downloadToolProgressModal: ModalNavigationController?
    private var downloadToolProgressView: DownloadToolProgressView?
    private var cancellables = Set<AnyCancellable>()
    
    private weak var presentInFlow: Flow?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(presentInFlow: Flow, appDiContainer: AppDiContainer, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface, didDownloadToolTranslations: @escaping ((_ result: Result<ToolTranslationsDomainModel, Error>) -> Void)) {
        
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
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completed in
            
            switch completed {
            case .finished:
                break
            case .failure(let error):
                self?.dismissDownloadTool(completion: {
                    self?.didDownloadToolTranslations(.failure(error))
                }, delaySeconds: 2)
            }
            
        }, receiveValue: { [weak self] (toolTranslations: ToolTranslationsDomainModel) in
            
            if let downloadToolProgressView = self?.downloadToolProgressView {
                downloadToolProgressView.completeDownloadProgress { [weak self] in
                    self?.dismissDownloadTool(completion: { [weak self] in
                        self?.didDownloadToolTranslations(.success(toolTranslations))
                    })
                }
            }
            else {
                self?.didDownloadToolTranslations(.success(toolTranslations))
            }
        })
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
        
        guard downloadToolProgressView == nil else {
            return
        }
        
        let viewModel = DownloadToolProgressViewModel(
            flowDelegate: self,
            toolId: determineToolTranslationsToDownload.getResource()?.id,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDownloadToolProgressInterfaceStringsUseCase: appDiContainer.feature.downloadToolProgress.domainLayer.getDownloadToolProgressInterfaceStringsUseCase()
        )
        
        let view = DownloadToolProgressView(viewModel: viewModel)
        
        let closeButton = AppCloseBarItem(
            color: ColorPalette.gtBlue.uiColor,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let hostingView = AppHostingController<DownloadToolProgressView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        let modal = ModalNavigationController.defaultModal(rootView: hostingView, statusBarStyle: .default)
        
        navigationController.present(modal, animated: true, completion: nil)
        
        downloadToolProgressView = view
        downloadToolProgressModal = modal
    }
    
    private func dismissDownloadTool(completion: (() -> Void)?, delaySeconds: TimeInterval? = nil) {
        
        guard let modal = downloadToolProgressModal else {
            return
        }
        
        delayCallbackSeconds(delaySeconds: delaySeconds) { [weak self] in
           
            modal.dismiss(animated: true, completion: completion)
            
            self?.downloadToolProgressView = nil
            self?.downloadToolProgressModal = nil
        }
    }
    
    private func delayCallbackSeconds(delaySeconds: TimeInterval?, closure: (() -> Void)?) {
        
        if let delaySeconds = delaySeconds {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                
                closure?()
            }
        }
        else {
            closure?()
        }
    }
}
