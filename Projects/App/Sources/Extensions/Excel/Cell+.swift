//
//  Cell+.swift
//  App
//
//  Created by 영준 이 on 2/1/26.
//
import CoreXLSX

extension Cell{
    func doubleValue(_ sharedStrings: SharedStrings) -> Double?{
        Double(self.stringValue(sharedStrings) ?? "")
    }
    
    func integerValue(_ sharedStrings: SharedStrings) -> Int?{
        guard let value = self.doubleValue(sharedStrings) else {
            return nil
        }
        
        return Int(value)
    }
}
