# DayOfWeekCollectionView

![Example 1](weekdaypicker.gif)

A simple UI component for controlling which days of the week a thing is active on.

## Installation

### Swift Package Manager



### CocoaPods

## Usage

The control is backed by an `OptionSet`.

Example:
```swift
let activeDays = DaysOfWeekActive.weekdaysOnly
let picker = DayOfWeekCollectionView(activeDays: activeDays)
```
```swift
picker.activeDays = .w
```

Produces:

![Example 2](weekdays.png)
