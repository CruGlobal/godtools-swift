//
//  TextViewLinksCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class TextViewLinksCoordinator: NSObject, UITextViewDelegate {
    
    private let textWithLinks: TextWithLinks
    private let didInteractWithUrlClosure: ((_ url: URL) -> Void)
    
    init(textWithLinks: TextWithLinks, didInteractWithUrlClosure: @escaping ((_ url: URL) -> Void)) {
        
        self.textWithLinks = textWithLinks
        self.didInteractWithUrlClosure = didInteractWithUrlClosure
        
        super.init()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
                
        didInteractWithUrlClosure(URL)
        
        return true
    }
}
