 //
//  DBProvide.swift
//  mvvm
//
//  Created by YinHao on 16/6/17.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreData
// MARK: 拓展NSManagerObject
extension NSManagedObject:jsonmodule,loadmodule,modifimodule{
    public func setjson(json: [String : AnyObject]) {
        for i in json{
            self.setValue(i.1, forKey: i.0)
        }
    }
    public class func getSimplejson(m:NSManagedObject) -> [String : AnyObject] {
        var c:Mirror? = Mirror(reflecting: m)
        var result:[String:AnyObject] = [:]
        repeat{
            for i in c!.children{
                if let s = m.valueForKey(i.label!){
                    if s.getjson != nil{
                        result[i.label!] = s.getjson!()
                    }else{
                        result[i.label!] = s
                    }
                }
            }
            c = c!.superclassMirror()
        }while (c != nil)
        return result
    }
    public func getjson()-> [String : AnyObject]{
        return [:]
    }
}
// MARK: core data stack
public class CoreDataStack{
    public static var filename = "data"
    public lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "cn.cheerapp.MyDiary" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(CoreDataStack.filename, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(CoreDataStack.filename).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    func count(Entity:String) -> Int {
        let request = NSFetchRequest(entityName: Entity)
        var error:NSError?
        let count = self.managedObjectContext.countForFetchRequest(request, error: &error)
        if error == nil{
            return count
        }else{
            return 0
        }
    }
    func deleteItem(item:NSManagedObject) {
        self.managedObjectContext.deleteObject(item)
    }
    func queryData<T:AnyObject>(name:String,sort:NSSortDescriptor)->[T]?{
        let request = NSFetchRequest(entityName: name)
        request.sortDescriptors = [sort]
        let datas = try? managedObjectContext.executeFetchRequest(request)
        if datas == nil{
            return nil
        }
        return datas as? [T]
    }
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
public class CoreDataProvide:NSObject,dataProvide{
    private static var queue = dispatch_queue_create("CoreDataProvideQueue", nil)
    private static var inst:CoreDataProvide?
    static func shareInstace()->CoreDataProvide{
        if inst == nil{
            inst = CoreDataProvide()
        }
        return inst!
    }
    override init() {
        super.init()
    }
    public func query(name:String,condition:Condition?,result:(data:[jsonmodule]?)->Void){
       let fetch = NSFetchRequest.make(condition, entity: name)
        asyncRun(CoreDataProvide.queue, clusure: {[weak self] in
            if self == nil{
                return
            }
            do{
                let array = try self!.stack.managedObjectContext.executeFetchRequest(fetch)
                result(data: array as? [jsonmodule])
            }catch{
                result(data: nil)
            }
        })
        
    }
    public func insert(m:[String:AnyObject],type:String) {
        asyncRun(CoreDataProvide.queue) { [weak self] in
            if self != nil{
                let desc = NSEntityDescription.entityForName(type, inManagedObjectContext: self!.stack.managedObjectContext)
                let k = NSManagedObject(entity: desc!, insertIntoManagedObjectContext: self!.stack.managedObjectContext)
                k.setjson(m)
                self!.stack.saveContext()
            }

        }
    }
    public func update(m: jsonmodule, type: String) {
        asyncRun(CoreDataProvide.queue) { [weak self] in
            if self != nil{
                self!.stack.saveContext()
            }
        }
    }
    public func count(type: String, condition: Condition?,Count:(NSNumber?)->Void) {
        let request = NSFetchRequest.make(condition, entity: type)
        asyncRun(CoreDataProvide.queue) {[weak self] in
            if self != nil{
                var error: NSError?
                let count = self?.stack.managedObjectContext.countForFetchRequest(request, error: &error)
                Count(count)
                if error != nil{
                    print(error)
                }
            }
        }
    }
    public func del(m: jsonmodule, type: String) {
        asyncRun(CoreDataProvide.queue) { [weak self] in
            if self != nil{
                self!.stack.managedObjectContext.deleteObject((m as! NSManagedObject))
                self!.stack.saveContext()
            }
        }
        
    }
    public func save() {
        self.stack.saveContext()
    }
    lazy var stack:CoreDataStack = {
        return CoreDataStack()
    }()
}
 extension NSFetchRequest{
    class func  make(condition:Condition?,entity:String)-> NSFetchRequest{
        let fetch = NSFetchRequest(entityName: entity)
        if condition == nil{
            return fetch
        }
        if condition!.limit != nil && condition!.page != nil{
            fetch.fetchLimit = condition!.limit!
            fetch.fetchOffset = condition!.page! * condition!.limit!
        }
        if condition!.compare != nil{
            fetch.predicate = NSPredicate(format: condition!.compare!, argumentArray: nil)
        }
        return fetch
    }
 }