Overview
==============
<!--
[![Pod Version](http://img.shields.io/cocoapods/v/Klendario.svg?style=flat)](https://github.com/ThXou/Klendario)
[![Pod Platform](http://img.shields.io/cocoapods/p/Klendario.svg?style=flat)](https://github.com/ThXou/Klendario)
[![Pod License](http://img.shields.io/cocoapods/l/Klendario.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)-->

Klendario is a Swift wrapper over the `EventKit` framework. It adds simplicity to the task of managing events in the iOS Calendar by providing handfull functions, extensions and the semi-automatic managment of the user authorization request to access the iOS calendar.

Install
==============

### Cocoapods

Add this line to your podfile:

```ruby
pod 'Klendario', '~> 1.0'
```

Usage
==============

Import `EventKit` and `Klendario` in your View Controller subclass:

```swift
import EventKit
import Klendario
```

Authorization
==============

Almost every call will check the user authorization status and returns an error in case the user has not authorized the access to the calendar. If the authorization has not been determined yet, the user is prompted to authorize the application. Anyway you can request authorization manually by calling:

```swift
Klendario.requestAuthorization { (granted, status, error) in
    if let error = error {
        print("error: \(error.localizedDescription)")
    } else {
        print("authorization granted!")
    }
}
```

The closure will return an error if the user has denied the access or if the access is restricted due to, for example, parental controls.
 
If you prefer, you can check if the user has granted access to the calendar using:

```swift
Klendario.isAuthorized()
```

Events
==============

### Creating events

Create an event is as easy as this:

```swift
let event = Klendario.newEvent()
event.title = "Awesome event"
event.startDate = Date()
event.endDate = Date().addingTimeInterval(60*60*2) // 2 hours
event.save()
```
If you have the specific calendar where you want to add the event, you can pass it in the `newEvent()` function as a parameter. If you additionaly want to perform some actions on saving, you can use the optional completion closure:

```swift
...
event.save { error in
   if let error = error {
      print("error: \(error.localizedDescription)")
   } else {
      print("event successfully created!")
   }
}
```

### Getting events
#### Get a single event

You can get an event by knowing its event identifier:

```swift
Klendario.getEvent(with: eventIdentifier) { (event, error) in
    guard let event = event else { return }
    print("got an event: \(event.title ?? "")")
}
```

#### Get a group of events

Or you can get a group of events between two dates and in specific calendars:

```swift
Klendario.getEvents(from: Date(),
                    to: Date() + 60*60*2,
                    in: calendars) { (events, error) in
                        guard let events = events else { return }
                        print("got \(events.count) events")
}
```

### Deleting events

You can easily delete an `EKEvent` object using the `delete` function:

```swift
event.delete()
```
As for creating an event, you can perform actions on event deletion completion. You can omit any paremeter:

```swift
event.delete(span: .futureEvents, commit: false) { error in
    if let error = error {
        print("error: \(error.localizedDescription)")
    } else {
        print("event successfully deleted!")
    }
}
```

Calendars
==============

### Creating calendars

Create a new calendar is as easy as create a new event:

```swift
let calendar = Klendario.newCalendar()
calendar.title = "Awesome calendar"
calendar.save()
```

As for events, you can use a `completion` closure to handle possible errors or perform some action on task completion. This method is flexible so you can pass a different `eventStore` or `source` if you don't want to use the default one.

### Getting calendars

To get all the iOS calendars which includes events in the device, simply call:

```swift
let calendars = Klendario.getCalendars()
```
### Deleting calendars

You can easily delete an `EKCalendar` object using the `delete` function:

```swift
calendar.delete()
```
As for creating an event, you can perform actions on event deletion completion. You can omit any paremeter:

```swift
calendar.delete(commit: true) { error in
	if let error = error {
        print("error: \(error.localizedDescription)")
    } else {
        print("calendar successfully deleted!")
    }
}
```

Last but not least
==============

To save an event or a calendar simply call `save()` on the object, as shown in the **Create Events** and the **Create calendars** sections. Be carefull to not call `save()` on objects not retrieved with the `Klendario` functions. `EventKit` does not support cross-store saving at least until iOS 12.