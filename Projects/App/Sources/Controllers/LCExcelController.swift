//
//  LCExcelController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
//set XMLDictionary/XMLDictionary.h of target membership for XlsxReaderWriter to public
import CoreXLSX

class LCExcelController : NSObject{
    var document : XLSXFile!;
    var workbook : Workbook!;
    var workSheetPaths: [String : String] = [:]
    var sharedStrings: SharedStrings!
    let headerRow: UInt = 1
    var defaultSheet : Worksheet!{
        get{
            try! self.document.parseWorksheet(at: workSheetPaths["기본_건배사"]!)
        }
    }
    
    var followSheet : Worksheet?{
        get{
            try! self.document.parseWorksheet(at: workSheetPaths["선,후창_건배사"]!)
        }
    }
    
    static let shared = LCExcelController();
    
    private(set) var categories : [LCToastCategory] = [];
    
    override init(){
        guard let excelUrl = Bundle.main.url(forResource: "cheers", withExtension: "xlsx") else{
            fatalError("Can not find Excel File");
        }
        print("excel : \(excelUrl)");
                if #available(iOS 16.0, *) {
                    self.document = .init(filepath: excelUrl.path(percentEncoded: false))
                } else {
                    self.document = .init(filepath: excelUrl.path)
                }
                
                self.workbook = try! document.parseWorkbooks().first
                self.workSheetPaths = try! document.parseWorksheetPathsAndNames(workbook: workbook)
                    .reduce(into: [String : String](), { dict, sheetPath in
                                dict[sheetPath.name ?? ""] = sheetPath.path
                            })
                self.sharedStrings = try! document.parseSharedStrings()
    }
    
    func loadFromFlie(){
        var followCategory : LCToastCategory = .init(name: "follow", image: nil)
        followCategory.name = "선창!후창~!"
        self.loadFollowToasts(withCategory: followCategory)
        self.categories.append(followCategory)
        
        self.categories.append(contentsOf: self.loadCategories())
    }
    
    public func loadHeaders(from sheet: Worksheet) -> [String : String] {
        guard let sharedStrings else {
            return [:]
        }
        
        return sheet.cells(atRows: [self.headerRow])
            .reduce(into: [String : String]()) { dict, cell in
                let columnId = cell.reference.column.value
                let cellValue = cell.stringValue(sharedStrings) ?? ""
                dict[columnId] = cellValue
            }
    }
    
    public func loadCells(of row: UInt, with headers: [String :  String], in sheet: Worksheet) -> [String : Cell] {
        return sheet.cells(atRows: [row])
            .reduce(into: [String : Cell]()) { dict, cell in
                let columnId = cell.reference.column.value
                guard let column = headers[columnId] else {
                    return
                }
                
                dict[column] = cell
            }
    }
    
    @discardableResult
    func loadCategories(categories : [LCToastCategory]? = nil) -> [LCToastCategory]{
        print("[start] load categories");
        let sheet = self.defaultSheet!
        let headers = self.loadHeaders(from: sheet)
        var i = 1;
        
        var newCategories : [String : LCToastCategory] = categories?.reduce(into: [:]) { dict, c in
            dict[c.name] = c
        } ?? [:]
        
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            
            guard let titleCell = cells[LCToast.FieldNames.title] else {
                break
            }
            
            let noCell = cells[LCToast.FieldNames.no]
            let contentsCell = cells[LCToast.FieldNames.contents]
            let categoryCell = cells[LCToast.FieldNames.category]
            
            let no = noCell?.integerValue(self.sharedStrings) ?? 0;
            let title = titleCell.stringValue(self.sharedStrings) ?? ""
            let contents = contentsCell?.stringValue(self.sharedStrings) ?? ""
            let category_name = categoryCell?.stringValue(self.sharedStrings) ?? ""
            
            guard !title.isEmpty else{
                break;
            }

            let toast = LCToast();
            toast.no = Int16(no);
            toast.title = title;
            toast.contents = contents;
            
            var category = newCategories[category_name];
            if category == nil{
                category = LCToastCategory(name: category_name, image: nil);
                newCategories[category_name] = category
            }
            category?.toasts.append(toast);
            
            i += 1;
        }
        
        print("[end] load categories[\(categories?.count ?? 0)]");
        return newCategories.values.map{ $0 };
    }
    
    func loadToasts(withCategory category : String) -> [LCToast]{
        print("[start] load toasts");
        let sheet = self.defaultSheet!
        let headers = self.loadHeaders(from: sheet)
        var i = 1;
        
        var value : [LCToast] = [];
        
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            
            guard let titleCell = cells[LCToast.FieldNames.title] else {
                break
            }
            
            let title = titleCell.stringValue(self.sharedStrings) ?? ""
            
            guard !title.isEmpty else{
                break;
            }
            
            let noCell = cells[LCToast.FieldNames.no]
            let contentsCell = cells[LCToast.FieldNames.contents]
            let categoryCell = cells[LCToast.FieldNames.category]
            
            let no = noCell?.integerValue(self.sharedStrings) ?? 0;
            let contents = contentsCell?.stringValue(self.sharedStrings) ?? ""
            let category_name = categoryCell?.stringValue(self.sharedStrings) ?? ""
            
            guard category.isEmpty || category_name == category else{
                i += 1;
                continue;
            }
            
            let toast = LCToast();
            toast.no = Int16(no);
            toast.title = title;
            toast.contents = contents;
            
            value.append(toast);
            
            i += 1;
        }
        
        print("[end] load toasts");
        return value;
    }
    
    @discardableResult
    func loadFollowToasts(withCategory category : LCToastCategory) -> [LCToast]{
        print("[start] load follow toasts");
        let sheet = self.followSheet!
        let headers = self.loadHeaders(from: sheet)
        var i = 1;
        var space = 1;
        
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            
            guard let noCell = cells[LCToast.FieldNames.no] else {
                break
            }
            
            let firstCell = cells[LCToast.FieldNames.first]
            let secondCell = cells[LCToast.FieldNames.second]
            let contentsCell = cells[LCToast.FieldNames.contents]
            
            let no = noCell.integerValue(self.sharedStrings) ?? 0;
            let first = firstCell?.stringValue(self.sharedStrings) ?? ""
            let second = secondCell?.stringValue(self.sharedStrings) ?? ""
            let contents = contentsCell?.stringValue(self.sharedStrings) ?? ""
//            var category_name = self.defaultSheet?.cell(forCellReference: "D\(i)")?.stringValue() ?? "";
            
            guard !first.isEmpty else{
                if space >= 0{
                    space -= 1;
                    i += 1;
                    continue;
                }
                break;
            }

            let toast = LCToast();
            toast.no = Int16(no);
            toast.title = "(선)\(first) (후)\(second)";
//            toast.contents = contents.isEmpty ? contents : "의미 : \(contents)";
            toast.contents = contents
            
            category.toasts.append(toast);
            
            i += 1;
        }
        
        print("[end] load follow toasts[\(category.toasts.count)]");
        return category.toasts;
    }

    func findToast(_ title : String, withCategory categoryName : String = "") -> LCToast?{
        var value : LCToast?;
        let categories = categoryName.isEmpty ? self.categories : self.categories.filter({ (c) -> Bool in
            return c.name == categoryName;
        });
        
        for cg in categories{
            for toast in cg.toasts{
                if toast.title == title{
                    value = toast;
                    break;
                }
            }
        }
        
        return value;
    }
    
    func randomToast(_ category : String = "") -> LCToast{
        var value : LCToast;
        var toasts : [LCToast] = [];
        let categories = category.isEmpty ? self.categories : self.categories.filter { (cg) -> Bool in
            return cg.name == category;
        }
        for cg in categories{
            toasts.append(contentsOf: cg.toasts);
        }
        
        let cnt = UInt32(toasts.count);
        value = toasts[Int(arc4random_uniform(cnt - 1))];
        
        return value;
    }
}
