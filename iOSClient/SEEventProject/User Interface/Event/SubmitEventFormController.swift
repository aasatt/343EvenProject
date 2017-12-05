//
//  SubmitEventFormController.swift
//  
//
//  Created by Aaron Satterfield on 11/29/17.
//

import Foundation
import Eureka
import SVProgressHUD

class SubmitNavigationController: UINavigationController {
    
    convenience init() {
        self.init(rootViewController: SubmitEventFormController())
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
    
}

class SubmitEventFormController: FormViewController {
    
    var selectedLocation: EventLocation?
    
    /// Enumerated row tags for easier coding
    enum rows: String {
        case title, description, imageUrl, location, links
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.submit))
        title = "New Event"
        configureForm()
    }
    
    /// Configure the submission form
    func configureForm() {
        form +++ Section()
            <<< TextRow(rows.title.rawValue){ row in
                row.title = nil
                row.placeholder = "Event Title"
            }
            <<< TextAreaRow(rows.description.rawValue){ row in
                row.placeholder = "Enter a description for the event"
            }
            <<< TextRow(rows.imageUrl.rawValue){ row in
                row.placeholder = "Add a link to an image"
            }
            <<< TextRow(rows.location.rawValue) {
                $0.cell.textField.isUserInteractionEnabled = false
                $0.placeholder = "Add Location"
                $0.cellUpdate({ (cell, row) in
                    cell.textField.textAlignment = .left
                })
                $0.onCellSelection({ (cell, row) in
                    self.present(LocationAutocompleteController(delegate: self), animated: true, completion: nil)
                })
            }
            let linksSection = MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                                   header: "External Links",
                                   footer: "Use this to add any news articles, live feeds or other sources.") {
                                    $0.addButtonProvider = { section in
                                        return ButtonRow(){
                                            $0.title = "Add New Link"
                                        }
                                    }
                                    $0.multivaluedRowToInsertAt = { index in
                                        return NameRow() {
                                            $0.placeholder = "URL"
                                        }
                                    }
                                    $0 <<< NameRow() {
                                        $0.placeholder = "URL"
                                    }
        }
        linksSection.tag = rows.links.rawValue
        form +++ linksSection
    }
    
    /// Verifies and creates an event from the inputted data
    func getEvent() -> Event? {
        guard var event = Event(id: UUID(),
                                title:
                                form.rowBy(tag: rows.title.rawValue)?.baseValue as? String,
                                imageUrl: form.rowBy(tag: rows.imageUrl.rawValue)?.baseValue as? String,
                                description: form.rowBy(tag: rows.description.rawValue)?.baseValue as? String) else {
            return nil
        }
        event.location = selectedLocation
        event.externalLinks = (form.sectionBy(tag: rows.links.rawValue) as? MultivaluedSection)?.values().map{ExternalLink(url: $0 as? String ?? "", title: $0 as? String ?? "")}
        return event
    }
    
}

extension SubmitEventFormController: LocationPickerDelegate {
    
    /// Called when the `LocationAutocompleteController` has a location selected. Adds the location to the event
    func didPickLocation(location: EventLocation) {
        selectedLocation = location
        (form.rowBy(tag: rows.location.rawValue) as? TextRow)?.value = location.title
    }
    
    /// Cancels event submission
    @objc
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Verifies and submits an event to the pending event list/mod queue
    @objc
    func submit() {
        guard let event = getEvent() else {
            return
        }
        SVProgressHUD.show()
        Session.sharedSession.submitEvent(event: event) { (succes) in
            DispatchQueue.main.async {
                self.handleSubmissionResult(success: succes)
            }
        }
    }
    
    /// Verifies the result of the submission, if it was successfull or not.
    func handleSubmissionResult(success: Bool) {
        if success {
            SVProgressHUD.showSuccess(withStatus: "Submitted!")
            SVProgressHUD.dismiss(withDelay: 2.0, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.presentAlert(title: "Error", description: "Please make sure you fill out all required fields.", dismissed: nil)
        }
    }
    
}
