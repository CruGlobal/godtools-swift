//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageHeaderViewModel: MobileContentViewModel {
    
    private let headerModel: Header
    
    private var mobileContentPageViewFactory: MobileContentPageViewFactory?
            
    init(headerModel: Header, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.headerModel = headerModel
        
        super.init(baseModel: headerModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
        
        for factory in renderedPageContext.viewRenderer.pageViewFactories.factories {
            if let mobileContentPageViewFactory = factory as? MobileContentPageViewFactory {
                self.mobileContentPageViewFactory = mobileContentPageViewFactory
            }
        }
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return UISemanticContentAttribute.from(languageDirection: renderedPageContext.language.direction)
    }
    
    var backgroundColor: UIColor {
        return headerModel.backgroundColor
    }
    
    func getNumber(numberLabel: UILabel) -> MobileContentTextView? {
        
        guard let numberTextModel = headerModel.number else {
            return nil
        }
        
        let numberLabelAttributes = MobileContentTextLabelAttributes(
            fontSize: 54,
            fontWeight: .regular,
            lineSpacing: nil,
            numberOfLines: 1
        )
        
        return mobileContentPageViewFactory?.getContentText(
            textModel: numberTextModel,
            renderedPageContext: renderedPageContext,
            viewType: .labelOnly(label: numberLabel, shouldAddLabelAsSubview: false),
            additionalLabelAttributes: numberLabelAttributes
        )
    }
    
    func getTitle(titleLabel: UILabel) -> MobileContentTextView? {
        
        guard let titleTextModel = headerModel.title else {
            return nil
        }
        
        let titleLabelAttributes = MobileContentTextLabelAttributes(
            fontSize: 19,
            fontWeight: .regular,
            lineSpacing: 2,
            numberOfLines: 0
        )
                
        return mobileContentPageViewFactory?.getContentText(
            textModel: titleTextModel,
            renderedPageContext: renderedPageContext,
            viewType: .labelOnly(label: titleLabel, shouldAddLabelAsSubview: false),
            additionalLabelAttributes: titleLabelAttributes
        )
    }
}
