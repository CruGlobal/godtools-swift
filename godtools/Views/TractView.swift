//
//  TractView.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractView: UIView {
    
    var contentView: TractPage?
    
    init(frame: CGRect, data: XMLIndexer, manifestProperties: ManifestProperties, configurations: TractConfigurations, parallelElement: BaseTractElement?, delegate: BaseTractElementDelegate) {
        super.init(frame: frame)
        
        let height = self.frame.size.height
        self.contentView = TractPage(startWithData: data,
                                     withMaxHeight: height,
                                     manifestProperties: manifestProperties,
                                     configurations: configurations,
                                     parallelElement: parallelElement)
        
        self.contentView?.setDelegate(delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        backgroundColor = .gtWhite        
        self.addSubview(self.contentView!.render())
    }
    
}
