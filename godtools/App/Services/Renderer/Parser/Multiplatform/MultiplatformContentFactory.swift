//
//  MultiplatformContentFactory.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentFactory {
    
    required init() {
        
    }
    
    static func getRenderableModel(content: Content) -> MobileContentRenderableModel? {
        
        let renderableModel: MobileContentRenderableModel?
        
        if let paragraph = content as? Paragraph {
            renderableModel = MultiplatformContentParagraph(paragraph: paragraph)
        }
        else if let text = content as? Text {
            renderableModel = MultiplatformContentText(text: text)
        }
        else if let button = content as? Button {
            renderableModel = MultiplatformContentButton(button: button)
        }
        else if let image = content as? Image {
            renderableModel = MultiplatformContentImage(image: image)
        }
        else if let inlineTip = content as? InlineTip, let tip = inlineTip.tip {
            return MultiplatformTrainingTip(tip: tip)
        }
        else if let card = content as? Card {
            return MultiplatformContentCard(contentCard: card)
        }
        else if let input = content as? Input {
            renderableModel = input
        }
        else if let link = content as? Link {
            renderableModel = link
        }
        else if let accordion = content as? Accordion {
            renderableModel = MultiplatformContentAccordion(accordion: accordion)
        }
        else if let multiSelect = content as? Multiselect {
            renderableModel = MultiplatformContentMultiSelect(multiSelect: multiSelect)
        }
        else if let flow = content as? GodToolsToolParser.Flow {
            return flow
        }
        else if let form = content as? Form {
            renderableModel = form
        }
        else if let tabs = content as? Tabs {
            renderableModel = MultiplatformContentTabs(tabs: tabs)
        }
        else if let spacer = content as? Spacer {
            renderableModel = MultiplatformContentSpacer(spacer: spacer)
        }
        else if let animation = content as? Animation {
            renderableModel = MultiplatformContentAnimation(animation: animation)
        }
        else if let video = content as? Video {
            renderableModel = MultiplatformContentVideo(video: video)
        }
        else {
            renderableModel = nil
        }
        
        return renderableModel
    }
}
