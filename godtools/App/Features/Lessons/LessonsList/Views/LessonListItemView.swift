//
//  LessonListItemView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonListItemView: UITableViewCell {
    
    static let nibName: String = "LessonListItemView"
    static let reuseIdentifier: String = "LessonListItemViewReuseIdentifier"
    
    private let lessonCornerRadius: CGFloat = 12
    
    private var viewModel: LessonListItemViewModelType?
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var lessonContentView: UIView!
    @IBOutlet weak private var bannerBackgroundView: UIView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    @IBOutlet weak private var bottomContentView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var attachmentsDownloadProgressView: UIView!
    @IBOutlet weak private var translationsDownloadProgressView: UIView!
    
    @IBOutlet weak private var attachmentsDownloadProgressWidth: NSLayoutConstraint!
    @IBOutlet weak private var translationsDownloadProgressWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        bannerImageView.image = nil
        titleLabel.text = ""
        setAttachmentsProgress(progress: 0, animated: false)
        setTranslationProgress(progress: 0, animated: false)
    }
    
    private func setupLayout() {
                
        // shadowView
        shadowView.layer.cornerRadius = lessonCornerRadius
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        shadowView.clipsToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        // lessonContentView
        lessonContentView.layer.cornerRadius = lessonCornerRadius
        lessonContentView.clipsToBounds = true
        
        // bannerImageView
        bannerImageView.contentMode = .scaleAspectFill
        bannerImageView.alpha = 0
        
        // bottomContentView
        bottomContentView.backgroundColor = .clear
        
        //
        setAttachmentsProgress(progress: 0, animated: false)
        setTranslationProgress(progress: 0, animated: false)
    }
    
    func configure(viewModel: LessonListItemViewModelType) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
        
        titleLabel.text = viewModel.title
        
        viewModel.bannerImage.addObserver(self) { [weak self] (bannerImage: UIImage?) in
            
            guard let bannerImageView = self?.bannerImageView else {
                return
            }
            
            bannerImageView.image = bannerImage
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                bannerImageView.alpha = 1
            }, completion: nil)
        }
        
        viewModel.attachmentsDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setAttachmentsProgress(progress: progress, animated: true)
        }
        
        viewModel.translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setTranslationProgress(progress: progress, animated: true)
        }
    }
    
    private func setAttachmentsProgress(progress: Double, animated: Bool) {
        
        UIView.setProgress(
            progress: progress,
            progressView: attachmentsDownloadProgressView,
            progressViewWidth: attachmentsDownloadProgressWidth,
            maxProgressViewWidth: lessonContentView.frame.size.width,
            layoutView: lessonContentView,
            animated: animated
        )
    }
    
    private func setTranslationProgress(progress: Double, animated: Bool) {
        
        UIView.setProgress(
            progress: progress,
            progressView: translationsDownloadProgressView,
            progressViewWidth: translationsDownloadProgressWidth,
            maxProgressViewWidth: lessonContentView.frame.size.width,
            layoutView: lessonContentView,
            animated: animated
        )
    }
}
