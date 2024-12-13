//
//  LCModelController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

class LCModelController : NSObject{
    struct EntityNames{
        static let FavoriteToast = "FavoriteToast";
    }
    static let FileName = "letscheers";
    
    internal static let dispatchGroupForInit = DispatchGroup();
    //    var SingletonQ = DispatchQueue(label: "RSModelController.Default");
    //private static var _instance = LCModelController();
    static let shared : LCModelController = {
        print("enter LCModelController instance - \(LCModelController.self) - \(Thread.current)");
        let value = LCModelController();
        
        print("wait LCModelController instance - \(LCModelController.self) - \(Thread.current)");
        LCModelController.dispatchGroupForInit.wait();
        print("exit LCModelController instance - \(Thread.current.description)");
        
        return value;
        /*get{
            //let timeout = DispatchTime.now() + DispatchTimeInterval.seconds(3);
            print("enter LCModelController instance - \(self) - \(Thread.current)");
            let value = _instance;
            //            value.waitInit();
            print("wait LCModelController instance - \(self) - \(Thread.current)");
            //            self.semaphore.signal();
            //            self.semaphore.wait();
            //            self.semaphore.wait(timeout: timeout);
            self.dispatchGroupForInit.wait();
            //            self.dispatchGroupForInit.notify(queue: DispatchQueue.main) {
            print("exit LCModelController instance - \(self) - \(Thread.current)");
            //            }
            
            return value;
        }*/
    }()
    static let semaphore = DispatchSemaphore.init(value: 1);
    //    {
    //        get{
    //            var value = self._instance;
    //            objc_sync_enter(self)
    //
    //            defer { objc_sync_exit(self) }
    //            print("return RSModelController instance");
    //            return value;
    //        }
    //    }
    
    var context : NSManagedObjectContext;
    internal override init(){
        //lock on
        //        objc_sync_enter(RSModelController.self)
        //        print("begin init RSModelController - \(RSModelController.self) - \(Thread.current)");
        //get path for model file
        //xcdatamodel => momd??
        guard let model_path = Bundle.main.url(forResource: LCModelController.FileName, withExtension: "momd") else{
            fatalError("Can not find Model File from Bundle");
        }
        
        //load model from model file
        guard let model = NSManagedObjectModel(contentsOf: model_path) else {
            fatalError("Can not load Model from File");
        }
        
        //create store controller??
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model);
        
        //create data context
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
        //set store controller??
        self.context.persistentStoreCoordinator = psc;
        //lazy load??
        //        var queue = DispatchQueue(label: "RSModelController.init", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil);
        DispatchQueue.global(qos: .background).async(group: LCModelController.dispatchGroupForInit) {
            print("begin init RSModelController");
            //        DispatchQueue.main.async{
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
            
            //get path for app's url
            var docUrl = urls.last;
            //create path for data file
            docUrl?.appendPathComponent(LCModelController.FileName);
            docUrl?.appendPathExtension("sqlite");
            let storeUrl = docUrl;
            do {
                //set store type?
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]);
            } catch {
                
            }
            
            //lock off
            //            objc_sync_exit(RSModelController.self);
            //            RSModelController.semaphore.signal();
            //RSModelController.dispatchGroupForInit.leave();
            print("end init RSModelController");
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func waitInit(){
        //        dispatchPrecondition(condition: .notOnQueue(<#T##DispatchQueue#>))
        while self.context.persistentStoreCoordinator?.persistentStores.isEmpty ?? false{
            sleep(1);
        }
    }
    
    func countForFavorites() -> Int{
        var value : Int = 0;
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.FavoriteToast);
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            value = try self.context.count(for: requester);
            print("count favorites. count[\(value)]");
        } catch let error{
            //fatalError("Can not load Stocks from DB. error[\(error.localizedDescription)]");
        }
        
        return value;
    }
    
    func loadFavorites(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([FavoriteToast], NSError?) -> Void)? = nil) -> [FavoriteToast]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [FavoriteToast] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.FavoriteToast);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [FavoriteToast];
            print("fetch favorites with predicate[\(predicate?.description ?? "")] count[\(values.count.description)]");
            completion?(values, nil);
        } catch let error{
            fatalError("Can not load Stocks from DB. error[\(error.localizedDescription)]");
        }
        
        return values;
    }
    
    func isExistFavorite(withName name : String) -> Bool{
        let predicate = NSPredicate(format: "name == \"\(name)\"");
        return !self.loadFavorites(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findFavorite(withName name : String) -> [FavoriteToast]{
        let predicate = NSPredicate(format: "name == \"\(name)\"");
        return self.loadFavorites(predicate: predicate, sortWays: nil);
    }
    
    @discardableResult
    func createFavorite(name: String, contents: String) -> FavoriteToast{
        let toast = NSEntityDescription.insertNewObject(forEntityName: EntityNames.FavoriteToast, into: self.context) as! FavoriteToast;
        
        toast.name = name;
//        toast.keyword = keyword;
        
        return toast;
    }
    
    func removeFavorite(toast: FavoriteToast){
        self.context.delete(toast);
    }
    
    func refresh(toast: FavoriteToast){
        self.context.refresh(toast, mergeChanges: false);
    }
    
    func reset(){
        self.context.reset();
    }
    
    var isSaved : Bool{
        return !self.context.hasChanges;
    }
    
    func saveChanges(){
        self.context.performAndWait {
            do{
                try self.context.save();
            } catch {
                fatalError("Save failed Error(\(error))");
            }
        }
    }
}
