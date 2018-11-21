//
//  Klendario.swift
//  Klendario
//
//  Created by Luis Cardenas on 20/11/2018.
//  Copyright © 2018 ThXou. All rights reserved.
//

import EventKit

///
public typealias KlendarioCompletion = (_ error: Error?) -> Void

///
public typealias KlendarioEventCompletion = (_ event: EKEvent?, _ error: Error?) -> Void

///
public typealias KlendarioEventsCompletion = (_ events: [EKEvent]?, _ error: Error?) -> Void

///
public typealias KlendarioAuthorizationCompletion = (_ granted: Bool, _ error: Error?) -> Void


public class Klendario {
    
    static let manager = Klendario()
    
    fileprivate let eventStore = EKEventStore()
    
    
    // MARK: - Authorization
    ///
    public class func requestAuthorization(_ completion: KlendarioAuthorizationCompletion? = nil) {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            completion?(true, nil)
        case .notDetermined:
            Klendario.manager.eventStore
                .requestAccess(to: .event) { (granted, error) in
                    completion?(granted, error)
            }
        case .restricted:
            completion?(false, KDError.authorizationFailed(reason: .authorizationRestricted))
        case .denied:
            completion?(false, KDError.authorizationFailed(reason: .authorizationDenied))
        }
    }
    
    /// Returns a boolean indicating if user has granted access to the device calendar.
    public class func isAuthorized() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    
    // MARK: - Events
    // MARK: - Creating events
    /// Creates an empty `EKEvent` object with the `eventStore`'s default calendar for new events.
    ///
    /// - parameter calendar: The calendar where to create the event. If `nil`, the `eventStore`'s default
    ///                         calendar for new events is used instead.
    public class func newEvent(in calendar: EKCalendar? = nil) -> EKEvent {
        let eventStore = Klendario.manager.eventStore
        
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        return event
    }
    
    
    // MARK: - Getting events
    /// Gets a single event matching the provided event `identifier`.
    ///
    /// - parameter identifier:     The event `identifier`.
    /// - parameter completion:     The `completion` closure called after the event search has been completed.
    public class func getEvent(with identifier: String, completion: KlendarioEventCompletion? = nil) {
        execute({
            let eventStore = Klendario.manager.eventStore
            let event = eventStore.event(withIdentifier: identifier)
            completion?(event, nil)
        }) { error in
            completion?(nil, error)
        }
    }
    
    /// Returns the events included between the provided start and end dates and are present in the provided `calendars`.
    ///
    /// - parameter date:           The start date from where to start searching for events.
    /// - parameter to:             The end date up to where to search for events.
    /// - parameter calendars:      Array of calendars where to seach for events.
    /// - parameter completion:     The `completion` closure called after the events search has been completed.
    public class func getEvents(from date: Date, to: Date, in calendars: [EKCalendar]? = nil, completion: KlendarioEventsCompletion? = nil) {
        execute({
            let eventStore = Klendario.manager.eventStore
            let predicate = eventStore.predicateForEvents(withStart: date, end: to, calendars: calendars)
            let events = eventStore.events(matching: predicate)
            completion?(events, nil)
        }) { error in
            completion?(nil, error)
        }
    }
    
    
    // MARK: - Removing events
    public class func deleteEvent(with identifier: String, span: EKSpan = .thisEvent, completion: KlendarioCompletion? = nil) {
        execute({
            getEvent(with: identifier, completion: { (event, error) in
                if let event = event {
                    event.delete(span: span) { error in
                        completion?(error)
                    }
                } else {
                    completion?(error)
                }
            })
        }, completion: completion)
    }
    

    // MARK: - Event store handling
    /// Resets the store by discarding uncommited changes to the store
    public class func resetStore() {
        Klendario.manager.eventStore.reset()
    }
    
    public class func commitChanges(_ completion: KlendarioCompletion? = nil) {
        executeAndThrow({
            try Klendario.manager.eventStore.commit()
            completion?(nil)
        }, completion: completion)
    }
    
    
    // MARK: - Calendars
    // MARK: - Getting calendars
    public class func getCalendars() -> [EKCalendar] {
        return Klendario.manager.eventStore.calendars(for: .event)
    }
    
    
    // MARK: - Private
    fileprivate class func execute(_ block: @escaping (() -> ()), completion: KlendarioCompletion? = nil) {
        requestAuthorization { (granted, error) in
            if granted {
                block()
            } else {
                completion?(error)
            }
        }
    }
    
    fileprivate class func executeAndThrow(_ block: @escaping (() throws -> ()), completion: KlendarioCompletion? = nil) {
        requestAuthorization { (granted, error) in
            if granted {
                do {
                    try block()
                }
                catch let error {
                    completion?(error)
                }
            } else {
                completion?(error)
            }
        }
    }
    
}


public extension EKEvent {
    /// Adds the event to the calendar.
    ///
    /// - parameter span:
    /// - parameter completion:
    public func save(span: EKSpan = .thisEvent, completion: KlendarioCompletion? = nil) {
        Klendario.executeAndThrow({
            try Klendario.manager.eventStore.save(self, span: span)
            completion?(nil)
        }, completion: completion)
    }
    
    public func delete(span: EKSpan = .thisEvent, commit: Bool = true, completion: KlendarioCompletion? = nil) {
        Klendario.executeAndThrow({
            try Klendario.manager.eventStore.remove(self, span: span, commit: commit)
            completion?(nil)
        }, completion: completion)
    }
}
