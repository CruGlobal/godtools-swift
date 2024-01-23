//
//  TextViewLinksCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

@available(iOS, obsoleted: 15.0, message: "When supporting iOS 15 and up use TextWithLinksView.swift")
class TextViewLinksCoordinator: NSObject, UITextViewDelegate {
    
    private let didInteractWithUrlClosure: ((_ url: URL) -> Bool)
    
    init(didInteractWithUrlClosure: @escaping ((_ url: URL) -> Bool)) {
        
        self.didInteractWithUrlClosure = didInteractWithUrlClosure
        
        super.init()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
                
        return didInteractWithUrlClosure(URL)
    }
}
