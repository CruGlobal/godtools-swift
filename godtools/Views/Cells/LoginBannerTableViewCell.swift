//
//  LoginBannerTableViewCell.swift
//  godtools
//
//  Created by Greg Weiss on 6/20/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class LoginBannerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topicLabel: UILabel!
    
    @IBOutlet weak var topicDescriptionLabel: UILabel!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupStyle() {
        topicLabel.text = "Want more GodTools?"
        topicDescriptionLabel.text = "Click Here to receive updates and hear how GodTools has impacted others."
        actionLabel.text = "Click Here"
        actionLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionTapped))
        actionLabel.addGestureRecognizer(tap)
        
    }
    
    @objc func actionTapped() {
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
    }
    
    
}
