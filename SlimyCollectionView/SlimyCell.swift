//
//  SlimyCell.swift
//  SlimyCollectionView
//
//  Created by Hiroto Ichinose on 2017/06/07.
//  Copyright © 2017年 hi-ro-to. All rights reserved.
//

import UIKit
import SDWebImage

class SlimyCell: UICollectionViewCell {
    private var imageView: UIImageView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // remove 1 view
        contentView.removeFromSuperview()

        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView?.image = nil
    }
    
    func configure(photoUrl: URL) {
        // animate feedin for good user interface
        imageView?.alpha = 0

        // add pop-in animation for good user interaction
        if let imageView = self.imageView {
            DispatchQueue.main.async {
                imageView.layer.cornerRadius = self.frame.size.width / 2
                imageView.clipsToBounds = true
            }

            // use cache if it exists by third-party framework
            imageView.sd_setImage(with: photoUrl, placeholderImage: nil, options: .retryFailed, completed: { img, error, type, url in
                UIView.animate(withDuration: 0.3) {
                    self.imageView?.alpha = 1
                }
            })
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // prevent auto resizing from cell
        return layoutAttributes
    }
    
    private func setupImageView() {
        guard imageView == nil else { return }

        var cellFrame = self.frame
        cellFrame.origin.x = 0
        cellFrame.origin.y = 0

        imageView = UIImageView(frame: cellFrame)
        imageView?.contentMode = .scaleAspectFill
        
        // do not use transparent subview
        imageView?.isOpaque = true

        addSubview(imageView!)
    }
}
