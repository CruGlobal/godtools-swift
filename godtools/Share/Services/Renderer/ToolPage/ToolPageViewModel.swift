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
    
    let backgroundImage: UIImage?
    let hidesBackgroundImage: Bool
    let contentStack: ObservableValue<ToolPageContentStackView?> = ObservableValue(value: nil)
    let headerNumber: String?
    let headerTitle: String?
    let hidesHeader: Bool
    let hero: ObservableValue<ToolPageContentStackView?> = ObservableValue(value: nil)
    let callToActionTitle: String?
    let callToActionTitleColor: UIColor
    let callToActionNextButtonColor: UIColor
    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, hidesBackgroundImage: Bool) {
        
        self.pageNode = pageNode
        self.manifest = manifest
        self.hidesBackgroundImage = hidesBackgroundImage
        
        if !hidesBackgroundImage, let backgroundSrc = manifest.resources[pageNode.backgroundImage ?? ""]?.src {
            backgroundImage = translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: backgroundSrc))
        }
        else {
            backgroundImage = nil
        }
                
        let pageHeaderNumber: String? = pageNode.header?.number
        let pageHeaderTitle: String? = pageNode.header?.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        headerNumber = pageHeaderNumber
        headerTitle = pageHeaderTitle
        self.hidesHeader = hidesHeader
        callToActionTitle = pageNode.callToAction?.text
        callToActionTitleColor = pageNode.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
        callToActionNextButtonColor = pageNode.callToAction?.getControlColor()?.color ?? pageNode.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryColor().color
        hidesCallToAction = pageNode.callToAction == nil
        
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        if firstNodeIsContentParagraph {
            contentStack.accept(value: renderContentStackView(node: pageNode, scrollIsEnabled: true))
        }
        
        if let heroNode = pageNode.hero {
            hero.accept(value: renderContentStackView(node: heroNode, scrollIsEnabled: true))
        }
    }
    
    func headerWillAppear() -> ToolPageHeaderViewModel {
        
        return ToolPageHeaderViewModel()
    }
    
    func callToActionWillAppear() {
        
    }
    
    private func renderContentStackView(node: MobileContentXmlNode, scrollIsEnabled: Bool) -> ToolPageContentStackView {
        
        let contentStackView: ToolPageContentStackView = ToolPageContentStackView(
            viewSpacing: 20,
            scrollIsEnabled: scrollIsEnabled
        )
        
        for childNode in node.children {
            let childView: UIView = recurseAndRender(node: childNode)
            contentStackView.addContentView(view: childView)
        }
        
        return contentStackView
    }
    
    private func recurseAndRender(node: MobileContentXmlNode) -> UIView {
        
        if let paragraphNode = node as? ContentParagraphNode {
            
            return renderContentStackView(node: paragraphNode, scrollIsEnabled: false)
        }
        else if let textNode = node as? ContentTextNode {
            
            let textLabel: UILabel = getLabel(text: textNode.text)
            textLabel.textColor = pageNode.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
            
            return textLabel
        }
        else if let headingNode = node as? HeadingNode {
            
            let headingLabel: UILabel = getLabel(text: headingNode.text)
            headingLabel.textColor = pageNode.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
            
            return headingLabel
        }
        
        return UIView(frame: .zero)
    }
    
    private func getButton(title: String?) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        
        return button
    }
    
    private func getLabel(text: String?) -> UILabel {
        
        let label: UILabel = UILabel()
        label.backgroundColor = UIColor.clear
        label.text = text
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        label.setLineSpacing(lineSpacing: 4)
        
        return label
    }
}
