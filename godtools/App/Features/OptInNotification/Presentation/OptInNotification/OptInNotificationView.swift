//
//  OptInNotificationView.swift
//  godtools
//
//  Created by Jason Bennett on 3/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct OptInNotificationView: View {
    
    private let overlayTappedClosure: (() -> Void)?
    
    @State private var isVisible: Bool = false
    
    @ObservedObject private var viewModel: OptInNotificationViewModel

    init(viewModel: OptInNotificationViewModel, overlayTappedClosure: (() -> Void)? = nil) {
       
        self.viewModel = viewModel
        self.overlayTappedClosure = overlayTappedClosure
    }

    var body: some View {
        
        GeometryReader { geometry in
         
            FullScreenOverlayView(tappedClosure: {
                
                setIsVisible(isVisible: false)
                
                overlayTappedClosure?()
            })
            .opacity(isVisible ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Spacer()
                
                VStack(alignment: .center, spacing: 0) {
                    
                    ImageCatalog.notificationGraphic
                        .image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 263, height: 140)
                        .padding(.horizontal, 15)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .padding(.horizontal, 5)
                                .foregroundColor(ColorPalette.gtBlue.color),
                            alignment: .bottom
                        )
                    
                    Text(viewModel.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextBold.font(size: 30))
                        .padding(.top, 20)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)

                    Text(viewModel.body)
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .foregroundStyle(ColorPalette.gtGrey.color)
                        .multilineTextAlignment(.center)
                        .padding(.top, 13)

                    Button(action: {
                        
                        setIsVisible(isVisible: false)
                        
                        viewModel.allowNotificationsTapped()

                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(ColorPalette.gtBlue.color)
                    }
                    .frame(height: 45)
                    .overlay(
                        Text(viewModel.notificationsActionTitle)
                            .foregroundColor(.white)
                    )
                    .padding(.top, 18)

                    Button(action: {
                        
                        setIsVisible(isVisible: false)

                        viewModel.maybeLaterTapped()

                    }) {
                        
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white)
                            
                            Text(viewModel.maybeLaterActionTitle)
                                .foregroundColor(ColorPalette.gtBlue.color)
                        }
                    }
                    .frame(height: 45)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                    
                }
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ColorPalette.gtBlue.color, lineWidth: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.white)
                        )
                )
                .padding(.horizontal, 20)
                .offset(y: !isVisible ? geometry.size.height * 0.75 : 0)
            }
        }
        .onAppear {
            setIsVisible(isVisible: true)
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    private func setIsVisible(isVisible: Bool) {
        withAnimation {
            self.isVisible = isVisible
        }
    }
}

// MARK: - Preview

struct OptInNotificationView_Preview: PreviewProvider {

    static func getOptInNotificationViewModel() -> OptInNotificationViewModel {

        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = OptInNotificationViewModel(
            flowDelegate: MockFlowDelegate(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewOptInNotificationUseCase: appDiContainer.feature.optInNotification.domainLayer.getViewOptInNotificationUseCase(),
            notificationPromptType: .allow
        )

        return viewModel
    }

    static var previews: some View {

        OptInNotificationView(
            viewModel: OptInNotificationView_Preview.getOptInNotificationViewModel()
        )
    }
}
