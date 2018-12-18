//
//  ViewController.swift
//
//  Copyright © 2018 Luis Cardenas. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import EventKit
import Klendario

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

