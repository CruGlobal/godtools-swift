//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardView: View {

    private let geometry: GeometryProxy
    private let layout: ToolCardLayout
    private let backgroundColor: Color = .white
    private let cornerRadius: CGFloat = 6
    private let cardWidth: CGFloat
    private let bannerImageAspectRatio: CGSize
    private let navButtons: [ToolCardNavButtonType]
    private let navButtonFont: Font = FontLibrary.sfProTextRegular.font(size: 14)
    private let navButtonWidth: CGFloat = 92
    private let navButtonHeight: CGFloat = 30
    private let navButtonSpacing: CGFloat = 8
    private let navButtonTitleHorizontalPadding: CGFloat?
    private let contentHorizontalInsets: CGFloat = 15
    private let showsCategory: Bool
    private let favoriteTappedClosure: (() -> Void)?
    private let toolDetailsTappedClosure: (() -> Void)?
    private let openToolTappedClosure: (() -> Void)?
    private let toolTappedClosure: (() -> Void)?
    
    @ObservedObject private var viewModel: ToolCardViewModel
    
    init(viewModel: ToolCardViewModel, geometry: GeometryProxy, layout: ToolCardLayout, showsCategory: Bool, navButtonTitleHorizontalPadding: CGFloat?, favoriteTappedClosure: (() -> Void)?, toolDetailsTappedClosure: (() -> Void)?, openToolTappedClosure: (() -> Void)?, toolTappedClosure: (() -> Void)?) {
        
        var navButtons: [ToolCardNavButtonType] = Array()
        
        if toolDetailsTappedClosure != nil {
            navButtons.append(.toolDetails)
        }
        
        if openToolTappedClosure != nil {
            navButtons.append(.openTool)
        }
                
        var cardWidth: CGFloat = 0
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.layout = layout
        self.navButtons = navButtons
        self.showsCategory = showsCategory
        self.navButtonTitleHorizontalPadding = navButtonTitleHorizontalPadding
        self.favoriteTappedClosure = favoriteTappedClosure
        self.toolDetailsTappedClosure = toolDetailsTappedClosure
        self.openToolTappedClosure = openToolTappedClosure
        self.toolTappedClosure = toolTappedClosure
        
        switch layout {
        
        case .landscape:
            bannerImageAspectRatio = CGSize(width: 335, height: 87)
            cardWidth = geometry.size.width - (DashboardView.contentHorizontalInsets * 2)
        
        case .thumbnail:
            bannerImageAspectRatio = CGSize(width: 190, height: 129)
            cardWidth = 190
        }
        
        // NOTE: minimumCardWidth is needed because cardWidth must be greater than the nav button widths and spacing since those are hard-coded into an HStack. ~Levi
        let navButtonCount: CGFloat = CGFloat(navButtons.count)
        let totalNavButtonWidth: CGFloat = navButtons.count > 0 ? (navButtonCount * navButtonWidth) + ((navButtonCount - 1) * navButtonSpacing) : 0
        let minimumCardWidth: CGFloat = (contentHorizontalInsets * 2) + totalNavButtonWidth
        
        if cardWidth < minimumCardWidth {
            cardWidth = minimumCardWidth
        }
    
        self.cardWidth = cardWidth
    }
    
    private var showsNavButtons: Bool {
        return !navButtons.isEmpty
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            AccessibilityTapAreaView(accessibilityIdentifier: viewModel.accessibilityWithToolName)
            
            backgroundColor
            
            VStack(alignment: .leading, spacing: 0) {
                
                OptionalImage(
                    imageData: viewModel.bannerImageData,
                    imageSize: .aspectRatio(width: cardWidth, aspectRatio: bannerImageAspectRatio),
                    contentMode: .fill,
                    placeholderColor: ColorPalette.gtLightestGrey.color
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(alignment: .center, spacing: 0) {
                        
                        Text(viewModel.name)
                            .font(FontLibrary.sfProTextBold.font(size: 17))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .lineLimit(2)
                        
                        if layout == .landscape, let languageAvailability = viewModel.languageAvailability {
                            
                            Spacer()
                            
                            ToolCardLanguageAvailabilityView(
                                languageAvailability: languageAvailability
                            )
                        }
                    }
                    
                    if showsCategory {
                        
                        ToolCardCategoryView(
                            category: viewModel.category
                        )
                        .padding([.top], 2)
                    }
                    
                    if layout == .thumbnail, let languageAvailability = viewModel.languageAvailability {
                        
                        ToolCardLanguageAvailabilityView(
                            languageAvailability: languageAvailability
                        )
                        .padding([.top], 5)
                    }
 
                    if showsNavButtons {

                        Spacer()
                        
                        HStack(alignment: .center, spacing: navButtonSpacing) {
                            
                            if layout == .landscape {
                                Spacer()
                            }
                            
                            GTWhiteButton(title: viewModel.detailsButtonTitle, font: navButtonFont, width: navButtonWidth, height: navButtonHeight, titleHorizontalPadding: navButtonTitleHorizontalPadding, accessibility: .toolDetails) {
                                
                                toolDetailsTappedClosure?()
                            }
                            
                            GTBlueButton(title: viewModel.openButtonTitle, font: navButtonFont, width: navButtonWidth, height: navButtonHeight, titleHorizontalPadding: navButtonTitleHorizontalPadding, accessibility: .openTool) {

                                openToolTappedClosure?()
                            }
                        }
                        .padding([.top], 10)
                    }
                }
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], contentHorizontalInsets)
            }
            
            HStack(alignment: .top, spacing: 0) {
                
                Spacer()
                
                ToolCardFavoritedButton(isFavorited: viewModel.isFavorited, tappedClosure: {
                    
                    favoriteTappedClosure?()
                })
            }
            
        }// end ZStack
        .frame(width: cardWidth)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
        .padding([.bottom], 10) // This padding is needed so the shadow isn't clipped.
        .contentShape(Rectangle()) // This fixes tap area not taking entire card into account.  Noticeable in iOS 14.
        .onTapGesture {
            
            toolTappedClosure?()
        }
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    
    static func getPreviewToolCardViewModel() -> ToolCardViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
            
        let tool = ToolListItemDomainModel(
            interfaceStrings: ToolListItemInterfaceStringsDomainModel(openToolActionTitle: "Open", openToolDetailsActionTitle: "Tool Details"),
            analyticsToolAbbreviation: "",
            dataModelId: "1",
            bannerImageId: "1",
            name: "Tool Name",
            category: "Tool Category",
            isFavorited: true,
            languageAvailability: ToolLanguageAvailabilityDomainModel(availabilityString: "is available", isAvailable: true)
        )
        
        return ToolCardViewModel(
            tool: tool,
            accessibility: .tool,
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
    }
    
    static var previews: some View {
        
        GeometryReader { geometry in
            
            let viewModel: ToolCardViewModel = ToolCardView_Previews.getPreviewToolCardViewModel()
            
            ToolCardView(
                viewModel: viewModel,
                geometry: geometry,
                layout: .landscape,
                showsCategory: true,
                navButtonTitleHorizontalPadding: nil,
                favoriteTappedClosure: nil,
                toolDetailsTappedClosure: nil,
                openToolTappedClosure: nil,
                toolTappedClosure: nil
            )
        }
    }
}
