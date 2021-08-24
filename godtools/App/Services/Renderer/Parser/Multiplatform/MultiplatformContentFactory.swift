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
              
        // TODO: Need to add the following:
        //    Animation
        //    Multiselect
        //    Multiselect.Option
        
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
        else if let input = content as? Input {
            renderableModel = MultiplatformContentInput(input: input)
        }
        else if let link = content as? Link {
            renderableModel = MultiplatformContentLink(link: link)
        }
        else if let fallback = content as? Fallback, let content = fallback.content.first {
            return getRenderableModel(content: content)
        }
        else if let accordion = content as? Accordion {
            renderableModel = MultiplatformContentAccordion(accordion: accordion)
        }
        else if let form = content as? Form {
            renderableModel = MultiplatformContentForm(form: form)
        }
        else if let tabs = content as? Tabs {
            renderableModel = MultiplatformContentTabs(tabs: tabs)
        }
        else if let spacer = content as? Spacer {
            renderableModel = MultiplatformContentSpacer(spacer: spacer)
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
