//
//  LCExcelController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
//set XMLDictionary/XMLDictionary.h of target membership for XlsxReaderWriter to public
import XlsxReaderWriter

class LCExcelController : NSObject{
    var document : BRAOfficeDocumentPackage?;
    var defaultSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("기본_건배사");
        }
    }
    
    var followSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("선,후창_건배사");
        }
    }
    
    static let Default = LCExcelController();
    
    var categories : [LCToastCategory] = [];
    
    override init(){
        guard let excel_path = Bundle.main.url(forResource: "cheers", withExtension: "xlsx") else{
            fatalError("Can not find Excel File");
        }
        print("excel : \(excel_path)");
        self.document = BRAOfficeDocumentPackage.open(excel_path.path);
//        var cell = sheet?.cell(forCellReference: "A2");
//        print("\(cell?.columnName()) - \(cell?.columnIndex()) => \(cell?.stringValue())");
    }
    
    func loadFromFlie(){
        self.loadCategories(categories: self.categories);
    }
    
    func loadCategories(categories : [LCToastCategory]? = nil) -> [LCToastCategory]{
        var value : [LCToastCategory] = [];
        var i = 1;
        var map : [String : LCToastCategory] = [:];
        var category : LCToastCategory!;
        
        if categories?.isEmpty == false{
            categories?.forEach({ (c) in
                c.toasts.removeAll();
                map[c.name] = c;
            })
        }
        
        while(true){
            var cell = self.defaultSheet?.cell(forCellReference: "A\(i)");
            var title = cell?.stringValue() ?? "";
            var contents = self.defaultSheet?.cell(forCellReference: "B\(i)")?.stringValue() ?? "";
            var category_name = self.defaultSheet?.cell(forCellReference: "C\(i)")?.stringValue() ?? "";
            
            if cell?.value != nil{
                title = cell?.value ?? "";
            }
            
            guard !title.isEmpty else{
                break;
            }

            var toast = LCToast();
            toast.title = title;
            toast.contents = contents;
            
            category = map[category_name];
            if category == nil{
                category = LCToastCategory(name: category_name, image: nil);
            }
            category?.toasts.append(toast);
            
            i += 1;
            title = self.defaultSheet?.cell(forCellReference: "A\(i)")?.stringValue() ?? "";
        }
        
        return value;
    }
    
    func loadToasts(withCategory category : String) -> [LCToast]{
        var value : [LCToast] = [];
        var i = 2;
        
        while(true){
            var title = self.defaultSheet?.cell(forCellReference: "A\(i)")?.stringValue() ?? "";
            var contents = self.defaultSheet?.cell(forCellReference: "B\(i)")?.stringValue() ?? "";
            var category_name = self.defaultSheet?.cell(forCellReference: "C\(i)")?.stringValue() ?? "";
            
            guard !title.isEmpty else{
                break;
            }
            
            guard category.isEmpty || category_name == category else{
                i += 1;
                continue;
            }
            
            var toast = LCToast();
            toast.title = title;
            toast.contents = contents;
            
            value.append(toast);
            
            i += 1;
        }
        
        return value;
    }
    
    func loadFollowToasts(withCategory category : LCToastCategory) -> [LCToast]{
//        var value : [LCToast] = category.toasts;
        var i = 2;
        var space = 1;
        
        while(true){
            var first = self.followSheet?.cell(forCellReference: "A\(i)")?.stringValue() ?? "";
            var second = self.followSheet?.cell(forCellReference: "B\(i)")?.stringValue() ?? "";
            var contents = self.followSheet?.cell(forCellReference: "C\(i)")?.stringValue() ?? "";
//            var category_name = self.defaultSheet?.cell(forCellReference: "D\(i)")?.stringValue() ?? "";
            
            guard !first.isEmpty else{
                if space >= 0{
                    space -= 1;
                    i += 1;
                    continue;
                }
                break;
            }

            var title = "(선)\(first) (후)\(second)";
            
            var toast = LCToast();
            toast.title = title;
//            toast.contents = contents.isEmpty ? contents : "의미 : \(contents)";
            toast.contents = contents
            
            category.toasts.append(toast);
            
            i += 1;
        }
        
        return category.toasts;
    }

    func findToast(_ title : String, withCategory categoryName : String = "") -> LCToast?{
        var value : LCToast?;
        var categories = categoryName.isEmpty ? self.categories : self.categories.filter({ (c) -> Bool in
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
        var categories = category.isEmpty ? self.categories : self.categories.filter { (cg) -> Bool in
            return cg.name == category;
        }
        for cg in categories{
            toasts.append(contentsOf: cg.toasts);
        }
        
        var cnt = UInt32(toasts.count);
        value = toasts[Int(arc4random_uniform(cnt - 1))];
        
        return value;
    }
}
