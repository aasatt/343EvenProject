//
//  EventHeaderView.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/10/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import UIKit

/// Header view at the top the the event discussion
class EventHeaderView: UIView {
    
    /// Backing image of event
    lazy var backgroundImage: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        i.backgroundColor = UIColor.lightGray
        return i
    }()
    /// Label for the title of the event
    var titleLabel: UILabel = {
        let l = UILabel()
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        addSubview(backgroundImage)
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    override func updateConstraints() {
        backgroundImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        super.updateConstraints()
    }
    
    /// Set the view with event data
    func set(event: Event) {
        backgroundImage.set(imageUrl: event.imageUrl)
    }
    
}
