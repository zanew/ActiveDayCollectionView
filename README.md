# DayOfWeekCollectionView

![](https://github.com/zanew/DayOfWeekCollectionView/blob/master/weekpicker.gif)

A simple UI component for controlling which days of the week a thing is active on.

## Installation

### Swift Package Manager

In Xcode got to File -> Swift Packages -> Add Package Dependency and paste in the repo's url: https://github.com/zanew/DayOfWeekCollectionView

## Usage

The control is backed by an `OptionSet`.

Example:
```swift
let activeDays = DaysOfWeekActive.weekdaysOnly
let weekCollectionView = DayOfWeekCollectionView(activeDays: activeDays)
```
Produces:
![](weekdays.png)

```swift
picker.activeDays = [.saturday, .sunday]
```
Produces:
![](weekends.png)

### Styling
```
weekCollectionView.backgroundColor = .secondarySystemGroupedBackground
weekCollectionView.badgeSelectionColor = .systemOrange
```
Produces:
![](style.png)



