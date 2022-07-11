//
//  TextWithLinks.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

struct TextWithLinks: UIViewRepresentable {
        
    private let text: String
    private let textColor: UIColor
    private let font: UIFont?
    private let lineSpacing: CGFloat?
    private let width: CGFloat
    private let linkTextColor: UIColor
    private let didInteractWithUrlClosure: ((_ url: URL) -> Bool)
        
    init(text: String, textColor: UIColor, font: UIFont?, lineSpacing: CGFloat?, width: CGFloat, linkTextColor: UIColor = .systemBlue, didInteractWithUrlClosure: @escaping ((_ url: URL) -> Bool)) {
        
        self.text = text
        self.textColor = textColor
        self.font = font
        self.lineSpacing = lineSpacing
        self.width = width
        self.linkTextColor = linkTextColor
        self.didInteractWithUrlClosure = didInteractWithUrlClosure
    }
    
    func makeCoordinator() -> TextViewLinksCoordinator {
        return TextViewLinksCoordinator(textWithLinks: self, didInteractWithUrlClosure: didInteractWithUrlClosure)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        let textView: UITextView = UITextView()
        
        textView.text = text
        
        if let lineSpacing = lineSpacing, !text.isEmpty {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            
            let attributedString: NSMutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
            
            attributedString.addAttribute(
                NSAttributedString.Key.paragraphStyle,
                value: paragraphStyle,
                range: (textView.text as NSString).range(of: text)
            )
            
            textView.attributedText = attributedString
        }
        
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = font
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes = [.foregroundColor: linkTextColor]
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                
        textView.translatesAutoresizingMaskIntoConstraints = false
        _ = textView.addWidthConstraint(constant: width)
        
        textView.delegate = context.coordinator
                
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        
        for constraint in textView.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = width
            }
        }
    }
}
