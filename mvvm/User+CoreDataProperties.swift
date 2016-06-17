//
//  User+CoreDataProperties.swift
//  mvvm
//
//  Created by YinHao on 16/6/17.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var name: String?
    @NSManaged var password: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var updatedAt: NSDate?

}
