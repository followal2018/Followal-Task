//
//  Array + Group.swift
//  followal
//
//  Created by Vivek Gadhiya on 26/02/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation

extension Array {
    
    func toIndexedDictionary(by selector: (Element) -> String) -> [Character : [Element]] {
        
        var dictionary: [Character : [Element]] = [:]
        
        for element in self {
            let selector = selector(element)
            guard let firstCharacter = selector.firstCharacter else { continue }
            
            if let list = dictionary[firstCharacter] {
                dictionary[firstCharacter] = list + [element]
            } else {
                // create list for new character
                dictionary[firstCharacter] = [element]
            }
        }
        return dictionary
    }
}

extension String {
    var firstCharacter : Character? {
        if count > 0 {
            return self[startIndex]
        }
        return nil
    }
}

extension Collection where Element: Hashable {
    var orderedSet: [Element] {
        var set: Set<Element> = []
        return reduce(into: []) { set.insert($1).inserted ? $0.append($1) : () }
    }
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}


extension Sequence {
    func groupSort(ascending: Bool = true, byDate dateKey: (Iterator.Element) -> Date) -> [[Iterator.Element]] {
        var categories: [[Iterator.Element]] = []
        for element in self {
            let key = dateKey(element)
            guard let dayIndex = categories.index(where: { $0.contains(where: { Calendar.current.isDate(dateKey($0), inSameDayAs: key) }) }) else {
                guard let nextIndex = categories.index(where: { $0.contains(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) }) else {
                    categories.append([element])
                    continue
                }
                categories.insert([element], at: nextIndex)
                continue
            }
            
            guard let nextIndex = categories[dayIndex].index(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) else {
                categories[dayIndex].append(element)
                continue
            }
            categories[dayIndex].insert(element, at: nextIndex)
        }
        return categories
    }
}


extension Array where Element : Collection, Element.Index == Int {
    func indices(where predicate: (Element.Iterator.Element) -> Bool) -> IndexPath? {
        for (i, row) in self.enumerated() {
            if let j = row.index(where: predicate) {
                return IndexPath(row: j, section: i)
                
            }
        }
        return nil
    }
}


extension Collection {
    func toJSONString() -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            return String(data: theJSONData,
                          encoding: .utf8)
        }
        return nil
    }
}
