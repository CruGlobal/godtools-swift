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
        self.titleLabel?.font = UIFont.gtRegular(size: 15.0)
        self.titleLabel?.text = "Download"
        self.setImage(UIImage(named: "download_white"), for: .normal)
        self.tintColor = .gtWhite
    }

}
