//
//  LoginBannerView.swift
//  godtools
//
//  Created by Greg Weiss on 6/20/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class LoginBannerView: UIView {
    
    var view: UIView!
    
//    @IBOutlet weak var topicLabel: UILabel!
//    @IBOutlet weak var topicDescriptionLabel: UILabel!
//    @IBOutlet weak var actionLabel: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    // MARK: - Lifecycle
    
//    static func create() -> LoginBannerView? {
//        let nib = UINib(nibName: "LoginBannerView", bundle: Bundle.main)
//        return nib.instantiate(withOwner: self, options: nil).first as? LoginBannerView
//    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: String(describing: LoginBannerView.self), bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }

//    private func commonInit() {
//        setupStyle()
//    }
    
//    func setupStyle() {
//        topicLabel.text = "Want more GodTools?"
//        topicDescriptionLabel.text = "Click Here to receive updates and hear how GodTools has impacted others."
//        actionLabel.text = "Click Here"
//        actionLabel.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(actionTapped))
//        actionLabel.addGestureRecognizer(tap)
//
//    }
    
    @objc func actionTapped() {
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        view.layer.shadowRadius = 3.0

        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

}
