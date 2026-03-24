//
//  ShareToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ShareToolFlow: Flow {
    
    private let toolId: String
    private let toolLanguageId: String
    private let pageNumber: Int
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, navigationController: AppNavigationController, toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel, toolAnalyticsAbbreviation: String) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = navigationController
        self.toolId = toolId
        self.toolLanguageId = toolLanguageId
        self.pageNumber = pageNumber
        
        let getShareToolStringsUseCase = appDiContainer.feature.shareTool.domainLayer.getShareToolStringsUseCase()
        
        getShareToolStringsUseCase
            .execute(
                toolId: toolId,
                toolLanguageId: toolLanguageId,
                pageNumber: pageNumber,
                appLanguage: appLanguage
            )
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ShareToolStringsDomainModel) in
        
                guard let weakSelf = self else {
                    return
                }
                            
                let shareToolView = weakSelf.getShareToolView(
                    strings: strings,
                    toolId: toolId,
                    toolAnalyticsAbbreviation: toolAnalyticsAbbreviation,
                    pageNumber: pageNumber
                )
                
                weakSelf.navigationController.present(shareToolView, animated: true)
            }
            .store(in: &cancellables)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .qrCodeTappedFromShareTool:
            
            appDiContainer
                .feature
                .shareTool
                .domainLayer
                .getShareToolQRCodeUseCase()
                .execute(
                    toolId: toolId,
                    toolLanguageId: toolLanguageId,
                    pageNumber: pageNumber
                )
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    
                } receiveValue: { [weak self] (shareToolQrCode: ShareToolQRCodeDomainModel) in

                    self?.navigationController.dismissPresented(animated: true, completion: { [weak self] in
                        self?.navigateToShareToolQRCode(shareUrl: shareToolQrCode.url)
                    })
                }
                .store(in: &cancellables)
            
        case .dismissedShareTool:
            completeFlow(state: .userClosed)
            
        case .closedTappedFromShareToolQrCode:
            completeFlow(state: .userClosed)
            
        default:
            break
        }
    }
    
    private func navigateToShareToolQRCode(shareUrl: URL) {
        
        let shareToolQrCode: UIViewController = getShareToolQRCodeView(shareUrl: shareUrl)
        
        navigationController.present(shareToolQrCode, animated: true)
    }
    
    private func completeFlow(state: ShareToolFlowCompletedState) {
        navigationController.dismissPresented(animated: true) { [weak self] in
            self?.flowDelegate?.navigate(step: .shareToolFlowCompleted(state: state))
        }
    }
}

extension ShareToolFlow {
    
    private func getShareToolView(strings: ShareToolStringsDomainModel, toolId: String, toolAnalyticsAbbreviation: String, pageNumber: Int) -> UIViewController {
                
        let viewModel = ShareToolViewModel(
            flowDelegate: self,
            strings: strings,
            toolId: toolId,
            toolAnalyticsAbbreviation: toolAnalyticsAbbreviation,
            pageNumber: pageNumber,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ShareToolView(viewModel: viewModel)
        
        return view.controller
    }
    
    private func getShareToolQRCodeView(shareUrl: URL) -> UIViewController {
        
        let viewModel = ShareToolQRCodeViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getShareToolQRCodeStringsUseCase: appDiContainer.feature.shareTool.domainLayer.getShareToolQRCodeStringsUseCase(),
            shareUrl: shareUrl
        )
        
        let view = ShareToolQRCodeView(
            viewModel: viewModel
        )
        
        let hostingView = AppHostingController<ShareToolQRCodeView>(
            rootView: view,
            navigationBar: nil
        )

        let overlayNavigationController = OverlayNavigationController(
            rootView: hostingView,
            hidesNavigationBar: true,
            navigationBarAppearance: nil
        )
        
        return overlayNavigationController
    }
}
