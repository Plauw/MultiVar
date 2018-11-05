//
//  MultiVar.swift
//  Mididone
//
//  Created by Joris Borst Pauwels on 07/03/2018.
//  Copyright © 2018 Joris Borst Pauwels. All rights reserved.
//

import Foundation


/*
 | Extensions on Set class that we are using for our MultiVar Class.
 |
 | We are extending the Set class for types that conform to Comparable
 | so that we can sort and provide a lowest/hightes value in the set.
 |
 | We are extenting the Set class so far explicitly for MultiVar types:
 | Int, Double, String and enums (conforming to RawRepresentable & Comparable).
 |
 */

extension Set where Element : Comparable {
    
    // Returns (sorted) lowest and respectivly highest value in the set
    public var lowest: Element? { return self.sorted().first }
    public var highest: Element? { return self.sorted().last }
}

extension Set where Element == Int { // BinaryInteger???
    
    // NOTE: these are sum/average of the set (which may have been reduced by duplicates!!).
    public var sum: Int {  return self.reduce(0, +)  } // ATTENTION/TODO: may overflow Int
    public var average: Double { return self.isEmpty ? 0 : Double(self.sum) / Double(self.count) }
    
    // Returns a Range-based view of the entire contents of self
    // This var is the equivilent to that in an IndexSet (however, now generic for a Set<Int>
    // since IndexSet does only support 0..<INT_MAX-1.)
    // A CountableRange is STRIDEABLE with integer steps (eg: 1,2,3,4,5) and is HALF OPEN
    // meaning upperbound is excluding from range and could represent an empty range (eg. 1..<1)
    // However, we are not including empty ranges.
    public var rangeView: [CountableRange<Element>] {
        
        var ranges: [CountableRange<Element>] = []
        var range: CountableRange<Element>?
        for v in self.sorted() {
            
            if range == nil {
                
                // Start the first range (one element: v)
                range = CountableRange<Element>(v...v)
            }
            else {
                
                // Note that upperbound is excluding
                if v > range!.upperBound {
                    
                    // Add the current range to the ranges and start a new one
                    ranges.append( range! )
                    range = CountableRange<Element>(v...v)
                }
                else {
                    
                    // Extent the range
                    range = CountableRange<Element>(range!.lowerBound...v)
                }
            }
        }
        
        if range != nil {
            
            ranges.append( range! )
        }
        
        return ranges
    }
    
    // Format the set in a 'rangeView way'
    public var formattedDescription: String { return formattedDescription( limitRangesTo: 16 ) }
    public func formattedDescription( limitRangesTo limit: Int ) -> String {
        
        var str = ""
        if self.rangeView.count > limit {
            
            str = "\(self.lowest!) ≤ i ≤ \(self.highest!)"
        }
        else {
            for countableRange in self.rangeView {
                
                str += str.isEmpty ? "" : ", "
                if countableRange.lowerBound == countableRange.upperBound - 1 {
                    
                    str += "\(countableRange.lowerBound)"
                }
                else {
                    
                    str += "\(countableRange.lowerBound)..\(countableRange.upperBound-1)"
                }
            }
        }
        
        return str
    }
}

extension Set where Element == String {
    
    // Format the set in a 'rangeView way'
    public var formattedDescription: String { return formattedDescription( limitRangesTo: 4 ) }
    public func formattedDescription( limitRangesTo limit: Int ) -> String {
        
        let sortedArray = self.sorted()
        var retStr: String?
        for (idx, str) in sortedArray.enumerated() {
            
            retStr = retStr == nil ? "'\(str)'" : retStr! + ", '\(str)'"
            
            if idx+1 == limit-1 && idx+1 != sortedArray.count-1 {
                
                break
            }
        }
        
        if sortedArray.count > limit && retStr != nil {
            
            retStr! += " ... '\(sortedArray.last!)'"
        }
        
        return retStr!
    }
}


extension Set where Element == Double {
    
    // NOTE: these are sum/average of the set (which may have been reduced by duplicates!!).
    public var sum: Double {  return self.reduce(0, +)  } // ATTENTION/TODO: may overflow Int
    public var average: Double { return self.isEmpty ? 0 : Double(self.sum) / Double(self.count) }
    
    // Format the set in a 'rangeView way'
    public var formattedDescription: String { return formattedDescription( limitRangesTo: 16 ) }
    public func formattedDescription( limitRangesTo limit: Int ) -> String {
        
        let sortedArray = self.sorted()
        var retStr: String?
        for (idx, val) in sortedArray.enumerated() {
            
            retStr = retStr == nil ? "'\(val)'" : retStr! + ", '\(val)'"
            
            if idx+1 == limit-1 && idx+1 != sortedArray.count-1 {
                
                break
            }
        }
        
        if sortedArray.count > limit && retStr != nil {
            
            retStr! += " ... '\(sortedArray.last!)'"
        }
        
        return retStr!
    }
}

extension Set where Element: RawRepresentable, Element : Comparable { // enums
    
    // Format the set in a 'rangeView way'
    public var formattedDescription: String { return formattedDescription( limitRangesTo: 4 ) }
    public func formattedDescription( limitRangesTo limit: Int ) -> String {
        
        let sortedArray = self.sorted()
        var retStr: String?
        for (idx, str) in sortedArray.enumerated() {
            
            retStr = retStr == nil ? "'\(str.rawValue)'" : retStr! + ", '\(str.rawValue)'"
            
            if idx+1 == limit-1 && idx+1 != sortedArray.count-1 {
                
                break
            }
        }
        
        if sortedArray.count > limit && retStr != nil {
            
            retStr! += " ... '\(sortedArray.last!.rawValue)'"
        }
        
        return retStr!
    }
}


/*
 | Our MultiVar Class deailing with Hasable objects.
 |
 | This class contains
 | - referenceValue: the value that will be presented to the user in case of multiple values (optional).
 | - values: a Set containing all unique values
 | - originals: all added values, unsorted (excluding referenceValue).
 | -
 */

class MultiVar<Element:Hashable>: NSObject {
    
    var values: Set<Element> = []
    var originals: [Element] = []
    var referenceValue: Element?
    var hasReferenceValue: Bool { return self.referenceValue == nil ? false : true }
    var hasMultipleValues: Bool { return values.count > 1 ? true : false }
    
    // For statistical purpose (calculating average)
    var addCount: Int { return self.originals.count }
    var uniqueCount: Int { return self.values.count }
    
    // Note that the reference value is optional and not included in the count (so not in average)
    init( withReferenceValue referenceValue: Element? ) {
        
        self.referenceValue = referenceValue
    }
    
    init( withReferenceValue referenceValue: Element?, andValues newValues: [Element]) {
        
        super.init()
        self.referenceValue = referenceValue
        self.add(newValues)
    }

    func add( _ newValue: Element ) {
        
        self.values.insert( newValue )
        self.originals.append( newValue )
    }
    
    func add( _ newValues: [Element] ) {
        
        for v in newValues {
            
            self.add( v )
        }
    }
    
    
    //
    // MARK: - NSObject
    // Override (debug) description of object
    //
    override open var description : String {
        
        var str = "MultiVar<\(Element.self)>"
        if let refVal = self.referenceValue { str += "\n\tRef. Val.:,\(refVal)" }
        str += "\n\tSet: \(self.values)>"
        return str
    }
}

extension MultiVar where Element : Comparable {
    
    var lowest: Element? { return values.sorted().first }
    var highest: Element? { return values.sorted().last }
}

extension MultiVar where Element == Int {
    
    var sum: Int { return self.originals.reduce( 0, + ) }
    var average: Double { return addCount == 0 ? 0 : Double(self.sum) / Double(self.addCount) }
    
    var valueString: String {
        
        return (self.hasReferenceValue && !self.hasMultipleValues) ? "\(self.referenceValue!)" : ""
    }
    
    var placeholderString: String? {
        
        return self.hasMultipleValues ? "Multiple values: " + self.values.formattedDescription : nil
    }
    
    var statsString: String {
        
        if self.values.count > 0 {
            
            return "Statistics\n\nSum is \(self.sum).\nTotal entries is \(self.addCount) of which \(self.uniqueCount) unique.\nAverage: \(Int(self.average)).\nRange: \(self.lowest!) ≤ i ≤ \(self.highest!)."
        }
        else {
            
            return "Statistics\n\nSum is \(self.sum).\nTotal entries is \(self.addCount) of which \(self.uniqueCount) unique."
        }
    }
}

extension MultiVar where Element == String {
    
    var valueString: String {
        
        return (self.hasReferenceValue && !self.hasMultipleValues) ? "\(self.referenceValue!)" : ""
    }
    
    var placeholderString: String? {
        
        return self.hasMultipleValues ? "Multiple values: " + self.values.formattedDescription : nil
    }
    
    var statsString: String {
        
        var str = "Statistics\n"
        str += "\nTotal entries is \(self.addCount) of which \(self.uniqueCount) unique."
        if self.values.count == 1 {
            
            str += "\nOne value: '\(self.lowest!)'."
        }
        else if self.values.count == 2 {
            
            str += "\nThese values: '\(self.lowest!)' & '\(self.highest!)'."
        }
        else if self.values.count > 2 {
            
            str += "\nRange: '\(self.lowest!)' ≤ i ≤ '\(self.highest!)'."
        }
        
        return str
    }
}

extension MultiVar where Element == Double {
    
    var sum: Double { return self.originals.reduce( 0, + ) }
    var average: Double { return addCount == 0 ? 0 : Double(self.sum) / Double(self.addCount) }
    
    var valueString: String {
        
        return (self.hasReferenceValue && !self.hasMultipleValues) ? "\(self.referenceValue!)" : ""
    }
    
    var placeholderString: String? {
        
        return self.hasMultipleValues ? "Multiple values: " + self.values.formattedDescription : nil
    }
    
    var statsString: String {
        
        if self.values.count > 0 {
            
            return "Statistics\n\nSum is \(self.sum).\nTotal entries is \(self.addCount) of which \(self.uniqueCount) unique.\nAverage: \(Int(self.average)).\nRange: \(self.lowest!) ≤ i ≤ \(self.highest!)."
        }
        else {
            
            return "Statistics\n\nSum is \(self.sum).\nTotal entries is \(self.addCount) of which \(self.uniqueCount) unique."
        }
    }
}

extension MultiVar where Element: Comparable, Element: RawRepresentable {
    
    var valueString: String {
        
        return (self.hasReferenceValue && !self.hasMultipleValues) ? "\(self.referenceValue!.rawValue)" : ""
    }
    
    var placeholderString: String? {
        
        return self.hasMultipleValues ? "Multiple values: " + self.values.formattedDescription : nil
    }
    
    var statsString: String {
        
        var str = "Statistics\n"
        str += "\nTotal entries is \(self.addCount) of which \(self.uniqueCount) unique."
        if self.values.count == 1 {
            
            str += "\nThis value: \(self.lowest!.rawValue)."
        }
        else if self.values.count == 2 {
            
            str += "\nThese two values: \(self.lowest!.rawValue) & \(self.highest!.rawValue)."
        }
        else if self.values.count > 2 {
            
            str += "\nRange: \(self.lowest!.rawValue) ≤ i ≤ \(self.highest!.rawValue)."
        }
        
        return str
    }
}
