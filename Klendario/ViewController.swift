//
//  ViewController.swift
//  Klendario
//
//  Created by Luis Cardenas on 20/11/2018.
//  Copyright © 2018 ThXou. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?

    fileprivate var events = [EKEvent]()
    fileprivate static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    // MARK: - Setup
    fileprivate func setup() {
        getEvents()
    }
    
    
    // MARK: - Helpers
    fileprivate func reload() {
        tableView?.reloadData()
    }
    
    fileprivate func getEvents() {
        // Getting events
        Klendario.getEvents(from: Date(), to: Date() + 60*60) { (events, error) in
            guard let events = events else {
                print("error getting events: \(String(describing: error))")
                return
            }
            
            self.events = events
            self.reload()
        }
    }
    
    fileprivate func createEvent(with title: String) {
        // Create event
        let event = Klendario.newEvent()
        event.title = title
        event.startDate = Date() + 60*60
        event.endDate = event.startDate.addingTimeInterval(60*60*2)
        
        event.save { error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            } else {
                self.getEvents()
                print("event successfully created!")
            }
        }
    }

    
    // MARK: - Actions
    @IBAction func createEvent(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New event", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Type the event title"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if let textField = alertController.textFields?.first, let text = textField.text {
                self.createEvent(with: text != "" ? text : "New title")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func reloadEvents(_ sender: UIButton) {
        getEvents()
    }

}


extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "\(ViewController.formatter.string(from: event.startDate)) - \(ViewController.formatter.string(from: event.endDate))"
        return cell
    }
}


extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

