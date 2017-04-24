//
//  DownloadButton.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class DownloadButton: GTButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cornerRadius = 5.0
        self.backgroundColor = UIColor.gtGreen
        self.color = UIColor.gtWhite
        self.tintColor = .gtWhite
        self.titleLabel?.font = UIFont.gtRegular(size: 15.0)
        self.setImage(UIImage(named: "download_white"), for: .normal)
        self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.increaseTitleWidth()
        self.translationKey = "download"
    }
    
    fileprivate func increaseTitleWidth() {
        var labelFrame = self.titleLabel?.frame
        labelFrame?.size.width = (labelFrame?.size.width)! + 30
        self.titleLabel?.frame = labelFrame!
    }

}
