//
//  EventInfoViewController.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 12/1/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import UIKit
import SafariServices

protocol EventInfoControllerDelegate {
    func didSelectLink(url: URL)
}

/// Shows the metadate about the current event
class EventInfoViewController: UIViewController {
    
    /// Current Event
    let event: Event
    let delegate: EventInfoControllerDelegate

    /// Label of the event name
    @IBOutlet weak var titleLabel: UILabel!
    /// Image view of the event
    @IBOutlet weak var imageView: UIImageView!
    /// Description of the event
    @IBOutlet weak var descriptionLabel: UILabel!
    /// Stack view tha helps layout the view, links are added here
    @IBOutlet weak var dataStackView: UIStackView!

    convenience init(event: Event, delegate: EventInfoControllerDelegate) {
        self.init(nibName: nil, bundle: nil, event: event, delegate: delegate)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, event: Event, delegate: EventInfoControllerDelegate) {
        self.event = event
        self.delegate = delegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = event.title
        imageView.set(imageUrl: event.imageUrl)
        descriptionLabel.text = event.description
        dataStackView.setCustomSpacing(20.0, after: descriptionLabel)
        self.addLinks()
    }
    
    /// Gets the links of the event and shows them in the stackview so they can be selected by the user
    func addLinks() {
        var tag = 0
        for link in event.externalLinks ?? [] {
            if tag == 0 {
                let l = UILabel()
                l.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
                l.textColor = descriptionLabel.textColor
                l.text = "Links:"
                dataStackView.addArrangedSubview(l)
            }
            let b = UIButton()
            b.titleLabel?.lineBreakMode = .byTruncatingTail
            b.setAttributedTitle(NSAttributedString(string: link.title, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, .foregroundColor: UIColor.blue, .font: UIFont.systemFont(ofSize: 14.0, weight: .light)]), for: .normal)
            b.tag = tag
            b.addTarget(self, action: #selector(self.didSelectLink(sender:)), for: .touchUpInside)
            dataStackView.addArrangedSubview(b)
            tag += 1
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// User selected a link, show them in safari
    @objc
    func didSelectLink(sender: UIButton) {
        guard let urlStr = event.externalLinks?[sender.tag].url, let url = URL(string: urlStr) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    

}
