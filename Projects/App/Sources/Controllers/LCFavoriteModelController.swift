//
//  LCFavoriteModelController.swift
//  letscheers
//
//  Created by 영준 이 on 2018. 4. 25..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import CoreData

class LCFavoriteModelViewController : NSObject, Sequence{
    typealias Element = FavoriteToast;
    
    static let EntityName = "FavoriteToast";
    lazy var fetchController : NSFetchedResultsController<NSFetchRequestResult>! = {
        var moc : NSManagedObjectContext!;
        DispatchQueue.main.syncInMain{
            moc = LCModelController.shared.context;
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: type(of: self).EntityName);
        request.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)];
        
        var value = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil);
        do{
            try value.performFetch();
        }catch let error{
            assertionFailure("Can not create fetcher for favorites");
        }
        
        return value;
    }();
    
    init(_ delegate: NSFetchedResultsControllerDelegate) {
        super.init();
        self.fetchController.delegate = delegate;
    }
    
    //private var fetched : Observable<[FavoriteToast]> = Variable<[FavoriteToast]>.init([FavoriteToast]([])).asObservable();
    func fetch(forSection section: Int, forIndex index: Int) -> FavoriteToast?{
        return self.fetchController.object(at: IndexPath.init(row: index, section: section)) as? FavoriteToast;
    }
    
    var fetchedGroupCount : Int{
        return self.fetchController.sections?.count ?? 0;
    }
    
    func fetchedCount(forGroup group: Int) -> Int{
        return self.fetchController.sections?[group].numberOfObjects ?? 0;
    }
    
    func removeFavorite(toast: FavoriteToast){
        self.fetchController.managedObjectContext.delete(toast);
        self.saveChanges();
    }
    
    func saveChanges(){
        let ctx = self.fetchController?.managedObjectContext;
        self.fetchController?.managedObjectContext.performAndWait { [weak ctx] in
            do{
                try ctx?.save();
                print("Saving favorite fetcher has been completed");
            } catch {
                assertionFailure("Saving favorite fetcher has been failed. Error(\(error))");
            }
        }
    }
    
    // MARK: Sequence
    func makeIterator() -> LCFavoriteModelIterator {
        return LCFavoriteModelIterator.init(self);
    }
}

public class LCFavoriteModelIterator : IteratorProtocol{
    public typealias Element = FavoriteToast
    
    weak var controller : LCFavoriteModelViewController!;
    var index : Int = 0;
    init(_ controller: LCFavoriteModelViewController) {
        self.controller = controller;
    }
    
    var count : Int{
        return self.controller.fetchedCount(forGroup: 0);
    }
    public func next() -> FavoriteToast? {
        var value : FavoriteToast?;
        guard self.index < self.count else{
            return value;
        }
        guard let favorite = self.controller.fetch(forSection: 0, forIndex: self.index) else{
            return value;
        }
        value = favorite;
        
        self.index += 1;
        return value;
    }
}
