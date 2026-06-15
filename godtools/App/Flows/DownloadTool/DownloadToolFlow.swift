//
//  DownloadToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

final class DownloadToolFlow: GTFlow {
    
    enum CompletedState {
        case downloadSuccess(toolTranslations: ToolTranslationsDomainModel)
        case downloadFailed(error: Error)
        case userClosed
    }
    
    private let appLanguage: AppLanguageDomainModel
    private let determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface
    
    private var downloadToolTask: Task<Void, Error>?
    private var flowCompleted: ((_ state: CompletedState) -> Void)?
    
    init(
        appDiContainer: AppDiContainer,
        appLanguage: AppLanguageDomainModel,
        determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface,
        flowCompleted: ((_ state: CompletedState) -> Void)? = nil
    ) {
        
        self.appLanguage = appLanguage
        self.determineToolTranslationsToDownload = determineToolTranslationsToDownload
        self.flowCompleted = flowCompleted
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getDownloadToolProgressView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                determineToolTranslationsToDownload: determineToolTranslationsToDownload
            ),
            stepEmitter: stepEmitter,
            onPresentType: .presentInitialView
        )
    }
    
    override func onPresented(animated: Bool) {
        
        downloadTool()
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }
        
        switch appStep {
            
        case .downloadToolSuccess(let toolTranslations):
            
            completeFlow(state: .downloadSuccess(toolTranslations: toolTranslations))
            
        case .downloadToolFailed(let error):
            
            presentError(appLanguage: appLanguage, error: error)
            completeFlow(state: .downloadFailed(error: error))
            
        case .closeTappedFromDownloadTool:
            cancelDownloadTool()
            completeFlow(state: .userClosed)

        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        
        parent?.stepEmitter.emit(step: AppFlowStep.downloadToolFlowCompleted(state: state))
        
        flowCompleted?(state)
    }
}

extension DownloadToolFlow {
    
    private func cancelDownloadTool() {
        downloadToolTask?.cancel()
        downloadToolTask = nil
    }

    private func downloadTool() {
        
        let appDiContainer: AppDiContainer = self.appDiContainer
        let downloadToolUseCase = appDiContainer.core.domainLayer.getDownloadToolUseCase()
                
        downloadToolTask = Task {
                        
            let navigationStep: AppFlowStep
            
            do {
                
                let toolTranslations = try await downloadToolUseCase
                    .execute(
                        filter: .downloadManifestAndRelatedFilesForRenderer,
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                        downloadType: .cacheElseRemote
                    )
                
                if let toolTranslations = toolTranslations {
                    navigationStep = .downloadToolSuccess(toolTranslations: toolTranslations)
                }
                else {
                    navigationStep = .downloadToolFailed(error: NSError.errorWithDescription(description: "Internal error. Failed to download tool translations."))
                }
            }
            catch let error {
                
                navigationStep = .downloadToolFailed(error: error)
            }
                        
            try await Task.sleep(for: .seconds(2))
            
            navigate(step: navigationStep)
        }
    }
    
    private static func getDownloadToolProgressView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface
    ) -> UIViewController {
        
        let viewModel = DownloadToolProgressViewModel(
            stepEmitter: stepEmitter,
            toolId: determineToolTranslationsToDownload.getResource()?.id,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDownloadToolProgressStringsUseCase: appDiContainer.feature.downloadToolProgress.domainLayer.getDownloadToolProgressStringsUseCase()
        )
        
        let view = DownloadToolProgressView(
            viewModel: viewModel
        )
        
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
        
        let modal = ModalNavigationController.defaultModal(
            rootView: hostingView,
            statusBarStyle: .default
        )
        
        return modal
    }
}
