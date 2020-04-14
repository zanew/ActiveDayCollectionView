//
//  DayOfWeekViewModel.swift
//  Sol
//
//  Created by Zane Whitney on 3/10/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//
import Foundation

// MARK: library
public struct DaysOfWeekActive: OptionSet {
    let rawValue: UInt
    
    static let sunday = DaysOfWeekActive(rawValue: 1 << 0)
    static let monday = DaysOfWeekActive(rawValue: 1 << 1)
    static let tuesday = DaysOfWeekActive(rawValue: 1 << 2)
    static let wednesday = DaysOfWeekActive(rawValue: 1 << 3)
    static let thursday = DaysOfWeekActive(rawValue: 1 << 4)
    static let friday = DaysOfWeekActive(rawValue: 1 << 5)
    static let saturday = DaysOfWeekActive(rawValue: 1 << 6)
    
    static let weekdaysOnly: DaysOfWeekActive = [.monday, .tuesday, .wednesday, .thursday, .friday]
}

class DayOfWeekViewModelBaseWrapper {
    var weekdaySetting: DaysOfWeekActive
    
    init(activeDays: DaysOfWeekActive) {
        self.weekdaySetting = activeDays
    }
    
    func dayOfWeekAbbreviated(forIndexPath indexPath: IndexPath) -> String {
        switch (indexPath.row) {
        case 0:
            return "S"
        case 1:
            return "M"
        case 2:
            return "T"
        case 3:
            return "W"
        case 4:
            return "T"
        case 5:
            return "F"
        case 6:
            return "S"
        default:
            return ""
        }
    }
    
    var numberOfItems: Int {
        return 7
    }
    
    func isDayOfWeekActive(atIndexPath indexPath: IndexPath) -> Bool {
        // if the 1s place bit is set, then the number will be odd
        return ((weekdaySetting.rawValue >> (indexPath.row)) % 2) == 1
    }
    
    func setDayOfWeekActive(state: Bool, forIndexPath indexPath: IndexPath) {
        let day = DaysOfWeekActive.init(rawValue: (1 << indexPath.row))
        
        if state {
            weekdaySetting.insert(day)
            print("Weekday Setting \(weekdaySetting)")
        } else {
            weekdaySetting.remove(day)
            print("Weekday Setting \(weekdaySetting)")
        }
    }
}

// MARK: library version
#if !FULL_WEEKDAY_PICKER
class DayOfWeekViewModel: DayOfWeekViewModelBaseWrapper {
    func isDayOfWeekActive(dayOfWeek: DaysOfWeekActive) -> Bool {
        return weekdaySetting.contains(dayOfWeek)
    }
}
// MARK: personal support for themeing, etc. as part of https://github.com/zanew/HueCircadianSchedule
#else
class DayOfWeekViewModel: DayOfWeekViewModelBaseWrapper, ThemeUpdating, NightLightResponding, PeriodicUpdateRegistering {
    var theme: Theme {
        didSet {
            updateTheme?(theme)
        }
    }
    
    var updateTheme: ((Theme?) -> Void)?
    
    var nightlight: Setting<Bool>?
            
    required init(withActiveDays activeDays: DaysOfWeekActive, nightLightSetting nightlight: Setting<Bool>) {
        self.nightlight = nightlight
        theme = nightlight.valueDescriptor ?? false ? .nightLight : SolarTime.theme(forSolarTime: CircadianManager.sharedInstance.solarTime)
        super.init(activeDays: activeDays)
    }
    
    func registerUpdaters() {
        registerForSolarTimeUpdates()
    }
}
#endif


