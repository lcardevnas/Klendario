//
//  Klendario.swift
//  Klendario
//
//  Created by Luis Cardenas on 20/11/2018.
//  Copyright © 2018 ThXou. All rights reserved.
//

import EventKit

/// A closure executed on calls which may return an error.
public typealias KlendarioCompletion = (_ error: Error?) -> Void

/// A closure executed when trying to get an event from calendar.
public typealias KlendarioEventCompletion = (_ event: EKEvent?, _ error: Error?) -> Void

/// A closure executed when trying to get a bunch of events from calendar.
public typealias KlendarioEventsCompletion = (_ events: [EKEvent]?, _ error: Error?) -> Void

/// A closure executed when requesting user authorization to the calendar.
public typealias KlendarioAuthorizationCompletion = (_ granted: Bool, _ status: EKAuthorizationStatus, _ error: Error?) -> Void


public class Klendario {
    
    /// A singleton object which mainly stored the default `eventStore`.
    fileprivate static let manager = Klendario()
    
    /// The default `eventStore` object to use in the get/add/remove tasks.
    fileprivate var eventStore = EKEventStore()
    
    
    // MARK: - Authorization
    /// Prompts the user to authorize event access to the Calendar if permission has not been yet determined. Otherwise
    /// it returns the specified error or access granted in case the user has authorized the access to the calendar.
    ///
    /// - parameter completion:     The `completion` closure called on the request access to the calendar.
    public class func requestAuthorization(_ completion: KlendarioAuthorizationCompletion? = nil) {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            completion?(true, status, nil)
        case .notDetermined:
            Klendario.manager.eventStore
                .requestAccess(to: .event) { (granted, error) in
                    completion?(granted, status, error)
            }
        case .restricted:
            completion?(false, status, KDError.authorizationFailed(reason: .authorizationRestricted))
        case .denied:
            completion?(false, status, KDError.authorizationFailed(reason: .authorizationDenied))
        }
    }
    
    /// Returns a boolean indicating if user has granted access to the device's calendar.
    public class func isAuthorized() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    
    // MARK: - Events
    // MARK: - Creating events
    /// Creates a new `EKEvent` object with the `eventStore`'s default calendar for new events.
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
    public class func getEvent(with identifier: String, completion: @escaping KlendarioEventCompletion) {
        execute({
            let eventStore = Klendario.manager.eventStore
            let event = eventStore.event(withIdentifier: identifier)
            DispatchQueue.main.async { completion(event, nil) }
        }) { error in
            DispatchQueue.main.async { completion(nil, error) }
        }
    }
    
    /// Returns the events included between the provided start and end dates and are present in the provided `calendars` array.
    ///
    /// - parameter date:           The start date from where to start searching for events.
    /// - parameter to:             The end date up to where to search for events.
    /// - parameter calendars:      An optional array of calendars where to seach for events.
    /// - parameter completion:     The `completion` closure called after the events search has been completed.
    public class func getEvents(from date: Date, to: Date, in calendars: [EKCalendar]? = nil, completion: @escaping KlendarioEventsCompletion) {
        execute({
            let eventStore = Klendario.manager.eventStore
            let predicate = eventStore.predicateForEvents(withStart: date, end: to, calendars: calendars)
            let events = eventStore.events(matching: predicate)
            DispatchQueue.main.async { completion(events, nil) }
        }) { error in
            DispatchQueue.main.async { completion(nil, error) }
        }
    }
    
    
    // MARK: - Removing events
    /// Deletes the event with the given event `identifier`.
    ///
    /// - parameter identifier:     The event identifier to delete.
    /// - parameter span:           Determines if the deletion should apply to this event only or all future events. If you omit
    ///                                 this parameter it is set by default to `.thisEvent`.
    /// - parameter completion:     The `completion` closure to be called after the event deletion.
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
    
    /// Commit the unsaved changes made to the `eventStore`.
    ///
    /// - parameter completion:     The `completion` closure to be called after the commit has been made.
    public class func commitChanges(_ completion: KlendarioCompletion? = nil) {
        executeAndThrow({
            try Klendario.manager.eventStore.commit()
            DispatchQueue.main.async { completion?(nil) }
        }, completion: completion)
    }
    
    
    // MARK: - Calendars
    // MARK: - Creating calendars
    /// Creates a new `EKCalendar` object in the `eventStore` object if provided. Otherwise uses the default one.
    ///
    /// - parameter eventStore: The eventStore where to create the calendar. If `nil`, the default `eventStore` is used.
    /// - parameter source:     The source where you want the calendar to be stored. If `nil`, `source`'s default calendar
    ///                             for new events is used.
    public class func newCalendar(in eventStore: EKEventStore? = nil, source: EKSource? = nil) -> EKCalendar {
        if let eventStore = eventStore {
            Klendario.manager.eventStore = eventStore
        }
        
        let calendar = EKCalendar(for: .event, eventStore: Klendario.manager.eventStore)
        calendar.source = source ?? Klendario.manager.eventStore.defaultCalendarForNewEvents?.source
        return calendar
    }
    
    
    // MARK: - Getting calendars
    /// Returns an array of calendars for the `.event` entity type.
    public class func getCalendars() -> [EKCalendar] {
        return Klendario.manager.eventStore.calendars(for: .event)
    }
    
    
    // MARK: - Private
    fileprivate class func execute(_ block: @escaping (() -> ()), completion: KlendarioCompletion? = nil) {
        requestAuthorization { (granted, _, error) in
            if granted {
                block()
            } else {
                completion?(error)
            }
        }
    }
    
    fileprivate class func executeAndThrow(_ block: @escaping (() throws -> ()), completion: KlendarioCompletion? = nil) {
        requestAuthorization { (granted, _, error) in
            if granted {
                do {
                    try block()
                } catch let error {
                    completion?(error)
                }
            } else {
                completion?(error)
            }
        }
    }
    
}


public extension EKEvent {
    /// Adds the event to the `eventStore`'s calendar.
    ///
    /// - parameter span:           Determines if the modifications made to the event should apply to this event only
    ///                                 or all future events.
    /// - parameter completion:     The `completion` closure to be called on add event completion.
    public func save(span: EKSpan = .thisEvent, completion: KlendarioCompletion? = nil) {
        Klendario.executeAndThrow({
            try Klendario.manager.eventStore.save(self, span: span)
            DispatchQueue.main.async { completion?(nil) }
        }, completion: completion)
    }
    
    /// Deletes the event from the `eventStore`'s calendar.
    ///
    /// - parameter span:           Determines if the deletion should apply to this event only or all future events.
    /// - parameter commit:         A boolean indicating if the event should be removed inmediatelly or after the next
    ///                                 `eventStore`'s `commit` call.
    /// - parameter completion:     The `completion` closure to be called after the event deletion.
    public func delete(span: EKSpan = .thisEvent, commit: Bool = true, completion: KlendarioCompletion? = nil) {
        Klendario.executeAndThrow({
            try Klendario.manager.eventStore.remove(self, span: span, commit: commit)
            DispatchQueue.main.async { completion?(nil) }
        }, completion: completion)
    }
}


public extension EKCalendar {
    /// Adds the calendar to the `eventStore`.
    ///
    /// - parameter commit:         A boolean indicating if the calendar should be removed inmediatelly or after the next
    ///                                 `eventStore`'s `commit` call.
    /// - parameter completion:     The `completion` closure to be called on add calendar completion.
    public func save(commit: Bool = true, completion: KlendarioCompletion? = nil) {
        Klendario.executeAndThrow({
            try Klendario.manager.eventStore.saveCalendar(self, commit: commit)
            DispatchQueue.main.async { completion?(nil) }
        }, completion: completion)
    }
    
    /// Deletes the calendar from the `eventStore`.
    ///
    /// - parameter commit:         A boolean indicating if the calendar should be removed inmediatelly or after the next
    ///                                 `eventStore`'s `commit` call.
    /// - parameter completion:     The `completion` closure to be called after the calendar deletion.
    public func delete(commit: Bool = true, completion: KlendarioCompletion? = nil) {
        Klendario.executeAndThrow({
            try Klendario.manager.eventStore.removeCalendar(self, commit: commit)
            DispatchQueue.main.async { completion?(nil) }
        }, completion: completion)
    }
}
