//
//  ShareToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

final class ShareToolFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case closed
    }
    
    private let toolId: String
    private let toolLanguageId: String
    private let pageNumber: Int
    private let appLanguage: AppLanguageDomainModel
                
    init(
        appDiContainer: AppDiContainer,
        toolId: String,
        toolLanguageId: String,
        pageNumber: Int,
        appLanguage: AppLanguageDomainModel,
        toolAnalyticsAbbreviation: String
    ) async {
        
        self.toolId = toolId
        self.toolLanguageId = toolLanguageId
        self.pageNumber = pageNumber
        self.appLanguage = appLanguage
        
        let getShareToolStringsUseCase = appDiContainer.feature.shareTool.domainLayer.getShareToolStringsUseCase()
        
        let strings = await getShareToolStringsUseCase
            .execute(
                toolId: toolId,
                toolLanguageId: toolLanguageId,
                pageNumber: pageNumber,
                appLanguage: appLanguage
            )
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getShareToolView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                strings: strings,
                toolId: toolId,
                toolAnalyticsAbbreviation: toolAnalyticsAbbreviation,
                pageNumber: pageNumber
            ),
            stepEmitter: stepEmitter
        )
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .qrCodeTappedFromShareTool:
            
            let result: Result<ShareToolQRCodeDomainModel, Error>
            
            do {
            
                let shareToolQrCode: ShareToolQRCodeDomainModel = try appDiContainer
                    .feature
                    .shareTool
                    .domainLayer
                    .getShareToolQRCodeUseCase()
                    .execute(
                        toolId: toolId,
                        toolLanguageId: toolLanguageId,
                        pageNumber: pageNumber
                    )
                
                result = .success(shareToolQrCode)
            }
            catch let error {
                
                result = .failure(error)
            }
            
            let appLanguage: AppLanguageDomainModel = self.appLanguage
            
            switch result {
                
            case .success(let shareToolQrCode):
                
                toggleInitialView(
                    view: getShareToolQRCodeView(
                        shareUrl: shareToolQrCode.url
                    ),
                    animated: true
                )
            
            case .failure(let error):
                
                completeFlow(state: .closed)
                
                presentError(
                    appLanguage: appLanguage,
                    error: error
                )
            }
            
        case .dismissedShareTool:
            completeFlow(state: .closed)
            
        case .closedTappedFromShareToolQrCode:
            completeFlow(state: .closed)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: ShareToolFlow.CompletedState) {
        dismissInitialView(animated: true, completion: { [weak self] in
            self?.parent?.stepEmitter.emit(step: AppFlowStep.shareToolFlowCompleted(state: state))
        })
    }
}

extension ShareToolFlow {
    
    private static func getShareToolView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        strings: ShareToolStringsDomainModel,
        toolId: String,
        toolAnalyticsAbbreviation: String,
        pageNumber: Int
    ) -> UIViewController {
                
        let viewModel = ShareToolViewModel(
            stepEmitter: stepEmitter,
            strings: strings,
            toolId: toolId,
            toolAnalyticsAbbreviation: toolAnalyticsAbbreviation,
            pageNumber: pageNumber,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ShareToolView(viewModel: viewModel)
        
        return view.controller
    }
    
    private func getShareToolQRCodeView(shareUrl: String) -> UIViewController {
        
        let viewModel = ShareToolQRCodeViewModel(
            stepEmitter: stepEmitter,
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
