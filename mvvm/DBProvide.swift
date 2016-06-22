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
extension NSManagedObject:jsonModule{
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
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(CoreDataStack.filename, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(CoreDataStack.filename).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext = {
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
    public func query(name:String,condition:Condition?,result:(data:[jsonModule]?)->Void){
       let fetch = NSFetchRequest.make(condition, entity: name)
        asyncRun(CoreDataProvide.queue, clusure: {[weak self] in
            if self == nil{
                return
            }
            do{
                let array = try self!.stack.managedObjectContext.executeFetchRequest(fetch)
                result(data: array as? [jsonModule])
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
    public func update(m: jsonModule, type: String) {
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
    public func del(m: jsonModule, type: String) {
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
            let express = condition!.compare!.key + condition!.compare!.op + condition!.compare!.value
            fetch.predicate = NSPredicate(format: express, argumentArray: nil)
        }
        return fetch
    }
 }