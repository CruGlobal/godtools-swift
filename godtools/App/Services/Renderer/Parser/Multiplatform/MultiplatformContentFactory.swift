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
            renderableModel = paragraph
        }
        else if let text = content as? Text {
            renderableModel = text
        }
        else if let button = content as? Button {
            renderableModel = button
        }
        else if let image = content as? Image {
            renderableModel = image
        }
        else if let inlineTip = content as? InlineTip, let tip = inlineTip.tip {
            renderableModel = tip
        }
        else if let card = content as? Card {
            renderableModel = card
        }
        else if let input = content as? Input {
            renderableModel = input
        }
        else if let link = content as? Link {
            renderableModel = link
        }
        else if let accordion = content as? Accordion {
            renderableModel = accordion
        }
        else if let multiselect = content as? Multiselect {
            renderableModel = multiselect
        }
        else if let flow = content as? GodToolsToolParser.Flow {
            return flow
        }
        else if let form = content as? Form {
            renderableModel = form
        }
        else if let tabs = content as? Tabs {
            renderableModel = tabs
        }
        else if let spacer = content as? Spacer {
            renderableModel = spacer
        }
        else if let animation = content as? Animation {
            renderableModel = animation
        }
        else if let video = content as? Video {
            renderableModel = video
        }
        else {
            renderableModel = nil
        }
        
        return renderableModel
    }
}
