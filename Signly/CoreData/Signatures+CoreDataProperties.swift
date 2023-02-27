//
//  Signatures+CoreDataProperties.swift
//  Signly
//
//  Created by Сергей Никитин on 07.09.2022.
//
//

import Foundation
import CoreData


extension Signatures {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Signatures> {
        return NSFetchRequest<Signatures>(entityName: "Signatures")
    }

    @NSManaged public var type: String
    @NSManaged public var brush: String
    @NSManaged public var penColor: String
    @NSManaged public var imageData: Data?
    @NSManaged public var pointsData: Data?
    @NSManaged public var createDate: Date
    
}
