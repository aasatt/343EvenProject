//
//  EventsCollectionViewController.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/9/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    convenience init() {
        self.init(rootViewController: EventsCollectionViewController())
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
    }
    
}


/// The main view once a user is authenticated. Shows all current events
class EventsCollectionViewController: UICollectionViewController {
    
    var events: [Event] = []


    private let reuseIdentifier = "Cell"
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        title = "Events"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.submitNew))
        self.collectionView?.register(UINib(nibName: "EventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: UIScreen.main.bounds.width/2.0-20, height: 224.0)
        collectionView?.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 8, right: 12)
        collectionView?.backgroundColor = .white
        fetchEvents()
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.addTarget(self, action: #selector(self.fetchEvents), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func fetchEvents() {
        Session.sharedSession.getActiveEvents { (fetchedEvents) in
            DispatchQueue.main.async {
                self.collectionView?.refreshControl?.endRefreshing()
                self.events = fetchedEvents ?? self.events
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc
    func submitNew() {
        present(SubmitNavigationController(), animated: true, completion: nil)
    }
 
}
extension EventsCollectionViewController {
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? EventCollectionViewCell else {
            fatalError("EventCollectionViewCell not registered")
        }
        cell.set(event: events[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(EventViewController(event: events[indexPath.item]), animated: true)
    }
   
}
