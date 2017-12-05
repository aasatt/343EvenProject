//
//  EventMessageTableViewCell.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/30/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import UIKit
import DateToolsSwift

class EventMessageTableViewCell: UITableViewCell {
    
    /// User image in cell
    lazy var userImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleToFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.heightAnchor.constraint(equalToConstant: 60).isActive = true
        i.widthAnchor.constraint(equalTo: i.heightAnchor).isActive = true
        i.layer.masksToBounds = true
        i.layer.cornerRadius = 5.0
        return i
    }()
    
    /// User display name label in the cell
    lazy var userLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        l.textColor = UIColor.darkText.withAlphaComponent(0.4)
        return l
    }()
    
    /// Message sent time label
    lazy var timelabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        l.textColor = UIColor.darkText.withAlphaComponent(0.6)
        return l
    }()
    
    /// Message text label - body
    lazy var bodyLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        l.textColor = UIColor.darkText.withAlphaComponent(0.8)
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        backgroundColor = .white
        addSubview(userImageView)
        addSubview(userLabel)
        addSubview(timelabel)
        addSubview(bodyLabel)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
        userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0).isActive = true
        userLabel.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 2).isActive = true
        userLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8).isActive = true
        timelabel.centerYAnchor.constraint(equalTo: userLabel.centerYAnchor).isActive = true
        timelabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: userLabel.leadingAnchor).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 6.0).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: timelabel.trailingAnchor).isActive = true
    }
    
    /// Sets the ui for the current message
    func set(message: Message) {
        userImageView.set(imageUrl: message.messageSender.imageUrl)
        userLabel.text = message.messageSender.displayName
        userLabel.sizeToFit()
        timelabel.text = message.sentOn.shortTimeAgoSinceNow
        timelabel.sizeToFit()
        bodyLabel.text = message.body
        bodyLabel.sizeToFit()
    }
    
    /// Gets the expected height of the cell with the message body
    static func cellHeight(with text: String) -> CGFloat {
        let l = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-92.0, height: 0))
        l.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        l.text = text
        l.numberOfLines = 0
        l.sizeToFit()
        return max(l.bounds.height+52.0, 92)
    }
    
}
