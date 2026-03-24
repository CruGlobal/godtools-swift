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
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, navigationController: AppNavigationController, toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel, toolAnalyticsAbbreviation: String) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = navigationController
        
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
            
            let shareToolQrCode: UIViewController = getShareToolQRCodeView()
            
            navigationController.dismissPresented(animated: true, completion: { [weak self] in
                self?.navigationController.present(shareToolQrCode, animated: true)
            })
            
        case .dismissedShareTool:
            completeFlow(state: .userClosed)
            
        case .closedShareQrCodeFromShareToolQrCode:
            completeFlow(state: .userClosed)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: ShareToolFlowCompletedState) {
        flowDelegate?.navigate(step: .shareToolFlowCompleted(state: state))
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
    
    private func getShareToolQRCodeView() -> UIViewController {
        
        let viewModel = ShareToolQRCodeViewModel(
            flowDelegate: self
        )
        
        let view = ShareToolQRCodeView(
            viewModel: viewModel
        )
        
        let hostingView = AppHostingController<ShareToolQRCodeView>(
            rootView: view,
            navigationBar: nil
        )
        
        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overCurrentContext
        
        return hostingView
    }
}
