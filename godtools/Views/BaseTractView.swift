//
//  BaseTractView.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class BaseTractView: UIView {
    var elements = [BaseTractElement]()
    var currentY = BaseTractElement.Standards.yPadding
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.frame = CGRect(x: 0,
//                            y: 0,
//                            width: UIScreen.main.bounds.size.width,
//                            height: UIScreen.main.bounds.size.height)
        
        backgroundColor = .orange
        
        let data = getData()
        let yPosition: CGFloat = 0.0
        let rootView: TractRoot = TractRoot(data: data, startOnY: yPosition)
        
//        let text = TextContent()
//        text.text = "Foo"
//        
//        let paragraph1 = Paragraph()
//        
//        let text2 = TextContent()
//        text2.text = "Some days you get the bear, and some days the bear gets you. Maybe if we felt any human loss as keenly as we feel one of those close to us, human history would be far less bloody. We finished our first sensor sweep of the neutral zone. Our neural pathways have become accustomed to your sensory input patterns. I can't. As much as I care about you, my first duty is to the ship. Congratulations - you just destroyed the Enterprise."
//        
//        let text3 = TextContent()
//        text3.text = "Bacon ipsum dolor amet elit shankle laboris pariatur shank dolor. In esse flank in. Brisket id anim dolore, cillum kevin sunt in lorem. Ut cillum turducken, pork belly laborum jowl dolore doner eu. Sirloin tempor pork loin aliqua ground round leberkas bresaola pork belly sunt incididunt boudin elit. Venison brisket aliqua, ut pork nulla laboris non turducken beef sirloin veniam pig. Minim ground round turducken, pancetta fatback cupim tempor laboris."
//        
//        let text4 = TextContent()
//        text4.text = "Hey there"
//        
//        paragraph1.children.append(text)
//        paragraph1.children.append(text2)
//        
//        elements.append(paragraph1)
//        elements.append(text3)
//        elements.append(text4)
//        
//        for element in elements {
//            
//            let view = element.render(yPos: currentY)
//            self.addSubview(view)
//            
//            currentY += view.frame.size.height + BaseTractElement.Standards.yPadding
//        }
    }
    
    func getData() -> Dictionary<String, Any> {
        let paragraphContent = [
            "kind": "text",
            "properties": ["message": "These four points explain how to enter into a personal relationship with God and experience the life for which you were created."],
            "children": []
            ] as [String : Any]
        
        let paragraph = [
            "kind": "paragraph",
            "properties": [],
            "children": [paragraphContent]
        ] as [String : Any]
        
        let headingContent = [
            "kind": "text",
            "properties": ["message": "Knowing God Personally"],
            "children": []
        ] as [String : Any]
        
        let heading = [
            "kind": "heading",
            "properties": [],
            "children": [headingContent]
        ] as [String : Any]
        
        let hero = [
            "kind": "hero",
            "properties": [],
            "children": [heading, paragraph]
        ] as [String : Any]
        
        let page = [
            "kind": "root",
            "properties": [],
            "children": [hero]
        ] as [String : Any]
        
        return page
    }
}
