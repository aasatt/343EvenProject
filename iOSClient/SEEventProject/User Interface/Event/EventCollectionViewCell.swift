//
//  EventCollectionViewCell.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/9/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import UIKit
import ChameleonFramework

/// The ui cell in the collection of events
class EventCollectionViewCell: UICollectionViewCell {
    
    /// Background event image for the cell
    @IBOutlet weak var eventImageView: UIImageView!
    /// Overlay view for image view with tint color
    @IBOutlet weak var colorOverlayView: UIView!
    /// Title label for the event in the cell
    @IBOutlet weak var eventTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Pass event modal to cell object so it can configure the UI outlets
    func set(event: Event) {
        eventTitleLabel.text = event.title
        eventImageView.set(imageUrl: event.imageUrl) { (image) in
            DispatchQueue.main.async {
                if let image = image {
                    let color = UIColor(averageColorFrom: image)
                    self.colorOverlayView.backgroundColor = color
                    self.eventTitleLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
                }
            }
        }
    }

}
