//
//  Date + Extension.swift
//  followal
//
//  Created by Vivek Gadhiya on 22/01/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation

extension String {
    
    func convertToDate(format: String) -> Date? {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = format
        return dateFmt.date(from: self)
    }
}

extension Date {
    func add(_ unit: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
    }
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
}
extension Date {
    
    // Convert local time to UTC (or GMT)
    func toGlobal() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocal() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func convertDate(toFormat: String) -> String {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = toFormat
        return dateFmt.string(from: self)
    }
    
    func compare(to date: Date) -> Bool {
        let order = NSCalendar.current.compare(self, to: date, toGranularity: .minute)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    
    func onlyTime() -> Date {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func ignoreTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    func datePhrase(withFormat: String = "MMMM dd, yyyy") -> String {
        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
        let components = Calendar.current.dateComponents(units, from: self, to: Date().toLocal())
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = withFormat
        
        if (components.day! > 0) {
            return (components.day! > 1 ? dateFmt.string(from: self) : Localization.yesterday.key.localized)
        } else {
            return Localization.today.key.localized 
        }
    }
    
    func datePhrasedate(withFormat: String = "MMMM dd, yyyy HH:mm a") -> String {

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = withFormat
        return dateFmt.string(from: self)
    }
    func datePhraseTime(withFormat: String = "MMMM dd, yyyy HH:mm a") -> String {
        
        var secondsAgo = Int(Date().timeIntervalSince(self))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute  {
            if secondsAgo < 2{
                return "just now"
            }else{
                return "\(secondsAgo) secs ago"
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            if min == 1{
                return "\(min) min ago"
            }else{
                return "\(min) mins ago"
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            if hr == 1{
                return "\(hr) hr ago"
            } else {
                return "\(hr) hrs ago"
            }
        } else if secondsAgo < week {
            let day = secondsAgo/day
            if day == 1{
                return "\(day) day ago"
            }else{
                return "\(day) days ago"
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = withFormat
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: self)
            return strDate
        }
    }
//    
//    func datePhraseTime(withFormat: String = "MMMM dd, yyyy HH:mm a") -> String {
//        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
//        let components = Calendar.current.dateComponents(units, from: self, to: Date().toLocal())
//        
//        let dateFmt = DateFormatter()
//        dateFmt.dateFormat = withFormat
//        
//        if (components.day! > 0) {
//            if components.day! > 1 {
//                return dateFmt.string(from: self)
//            } else {
//                dateFmt.dateFormat = "hh:mm a"
//
//                return Localization.yesterday.key.localized + " " + dateFmt.string(from: self)
//            }
//        } else {
//            dateFmt.dateFormat = "hh:mm a"
//            return Localization.today.key.localized + " " + dateFmt.string(from: self)
//        }
//    }
    
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        print(calendar.shortQuarterSymbols)
        print(calendar.veryShortWeekdaySymbols)
        return calendar.weekdaySymbols
        
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
}


