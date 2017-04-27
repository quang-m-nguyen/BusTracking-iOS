//
//  Alarms+CoreDataProperties.swift
//  
//
//  Created by Quang Nguyen on 8/26/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Alarms {

    @NSManaged var busstop: String?
    @NSManaged var lat: NSNumber?
    @NSManaged var lng: NSNumber?
    @NSManaged var busroute: String?

}
