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
    var currentY = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: UIScreen.main.bounds.size.width,
                            height: UIScreen.main.bounds.size.height)
        
        let paragraph = Paragraph(xml: nil,
                                  rootView: self,
                                  parent: nil)
        
        let textContent = TextContent(xml: nil,
                                      rootView: self,
                                      parent: paragraph)
        
        textContent.text = "Maybe we better talk out here; the observation lounge has turned into a swamp. For an android with no feelings, he sure managed to evoke them in others. How long can two people talk about nothing? Commander William Riker of the Starship Enterprise. Fear is the true enemy, the only enemy. Well, that's certainly good to know."
        
        
        let textContent2 = TextContent(xml: nil,
                                       rootView: self,
                                       parent: paragraph)
        
        textContent2.text = "Foo barsky"
        
        paragraph.children.append(textContent)
        paragraph.children.append(textContent2)
        
        elements.append(paragraph)
        
        backgroundColor = .orange
        
        for element in elements {
            self.addSubview(element.render())
        }
    }    
}
