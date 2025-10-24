//
//  TractPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class TractPageHeaderViewModel: MobileContentViewModel {
    
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
    
    var backgroundColor: UIColor {
        return headerModel.backgroundColor.toUIColor()
    }
    
    func getNumber(numberLabel: UILabel) -> MobileContentTextView? {
        
        guard let numberTextModel = headerModel.number else {
            return nil
        }
        
        let numberLabelAttributes = MobileContentTextLabelAttributes(
            fontSize: 54,
            fontWeight: .regular,
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
