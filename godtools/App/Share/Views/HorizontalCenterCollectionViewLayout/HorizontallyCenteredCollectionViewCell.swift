//
//  HorizontallyCenteredCollectionViewCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

protocol HorizontallyCenteredCollectionViewCell {
    
    func horizontallyCenteredCellWillAppearWithPercentageVisible(percentageVisible: CGFloat, animated: Bool)
    func horizontallyCenteredCellDidUpdatePercentageVisible(percentageVisible: CGFloat, animated: Bool)
}
