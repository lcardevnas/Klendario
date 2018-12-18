Overview
==============

[![Pod Version](http://img.shields.io/cocoapods/v/Klendario.svg?style=flat)](https://github.com/ThXou/Klendario)
[![Pod Platform](http://img.shields.io/cocoapods/p/Klendario.svg?style=flat)](https://github.com/ThXou/Klendario)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pod License](http://img.shields.io/cocoapods/l/Klendario.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)

Klendario is a Swift wrapper over the `EventKit` framework. It adds simplicity to the task of managing events in the iOS Calendar by providing handfull functions, extensions and the semi-automatic managment of the user authorization request to access the iOS calendar.

Requirements
==============

* iOS 9.0+
* Xcode 10.0+
* Swift 4.2+

Install
==============

### Cocoapods

Add this line to your podfile:

```ruby
pod 'Klendario'
```

### Carthage

Add this line to your `cartfile`:

```ruby
github "ThXou/Klendario" "master"
```

And then follow the official documentation about [Adding frameworks to an application](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

Setup
==============

Import `Klendario` in your source file:

```swift
import Klendario
```

Then set the `NSCalendarsUsageDescription` usage description key in your app's `Info.plist` file to avoid the Xcode crash on access to sensitive data.

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

Before saving events read the [Last but not least](#last) section.

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
Before deleting events read the [Last but not least](#last) section.

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

Before saving calendars read the [Last but not least](#last) section.

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
Before deleting calendars read the [Last but not least](#last) section.

<a name="last"></a>Last but not least
==============

It is very simple to save or delete an event or a calendar with `Klendario`, you just need to call `save()` or `delete()` on the object as shown in previous sections. **Be carefull** to not call `save()` or `delete()` on objects not retrieved with the `Klendario` API, because it shares the same `EKEventStore` object across all the API calls.

`EventKit` does not support cross-store saving at least until iOS 12.