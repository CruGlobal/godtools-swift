//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: ToolPageViewModelType {
        
    private let pageNode: PageNode
    private let manifest: MobileContentXmlManifest
    private let primaryColor: UIColor
    private let primaryTextColor: UIColor
        
    let backgroundImage: UIImage?
    let hidesBackgroundImage: Bool
    let hidesCards: Bool
    
    required init(pageNode: PageNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, hidesBackgroundImage: Bool) {
        
        let primaryColor: UIColor = pageNode.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryColor().color
        let primaryTextColor: UIColor = pageNode.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
        
        self.pageNode = pageNode
        self.manifest = manifest
        self.primaryColor = primaryColor
        self.primaryTextColor = primaryTextColor
        self.hidesBackgroundImage = hidesBackgroundImage
        
        if !hidesBackgroundImage, let backgroundSrc = manifest.resources[pageNode.backgroundImage ?? ""]?.src {
            backgroundImage = translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: backgroundSrc))
        }
        else {
            backgroundImage = nil
        }
        
        hidesCards = pageNode.cardsNode?.cards.isEmpty ?? true
    }
    
    func contentStackWillAppear() -> ToolPageContentStackViewModel? {
        
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        
        if firstNodeIsContentParagraph {
            
            return ToolPageContentStackViewModel(
                node: pageNode,
                itemSpacing: 20,
                scrollIsEnabled: true,
                defaultPrimaryColor: primaryColor,
                defaultPrimaryTextColor: primaryTextColor
            )
        }
        
        return nil
    }
    
    func headerWillAppear() -> ToolPageHeaderViewModel {
        
        return ToolPageHeaderViewModel(
            pageNode: pageNode,
            backgroundColor: primaryColor,
            primaryTextColor: primaryTextColor
        )
    }
    
    func heroWillAppear() -> ToolPageContentStackViewModel? {
        
        if let heroNode = pageNode.heroNode {
            
            return ToolPageContentStackViewModel(
                node: heroNode,
                itemSpacing: 20,
                scrollIsEnabled: true,
                defaultPrimaryColor: primaryColor,
                defaultPrimaryTextColor: primaryTextColor
            )
        }
        
        return nil
    }

    func cardsWillAppear() -> [ToolPageCardViewModel] {
        
        let cards: [CardNode] = pageNode.cardsNode?.cards ?? []
        var viewModels: [ToolPageCardViewModel] = Array()
        
        for cardNode in cards {
            let cardViewModel = ToolPageCardViewModel(cardNode: cardNode)
            viewModels.append(cardViewModel)
        }
        
        return viewModels
    }
    
    func callToActionWillAppear() -> ToolPageCallToActionViewModel {
        
        return ToolPageCallToActionViewModel(
            pageNode: pageNode,
            primaryColor: primaryColor,
            primaryTextColor: primaryTextColor
        )
    }
}
