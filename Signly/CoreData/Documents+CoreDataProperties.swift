//
//  Documents+CoreDataProperties.swift
//  Signly
//
//  Created by Сергей Никитин on 10.09.2022.
//
//

import Foundation
import CoreData


extension Documents {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Documents> {
        return NSFetchRequest<Documents>(entityName: "Documents")
    }

    @NSManaged public var documentId: String
    @NSManaged public var data: Data?
    
}
