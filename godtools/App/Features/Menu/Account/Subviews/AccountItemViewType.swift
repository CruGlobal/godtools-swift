//
//  AccountItemViewType.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol AccountItemViewDelegate: AnyObject {
    func accountItemViewDidProcessAlertMessage(itemView: AccountItemViewType, alertMessage: AlertMessageType)
}

protocol AccountItemViewType: UIView {
    var delegate: AccountItemViewDelegate? { get set }
}
