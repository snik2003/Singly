//
//  String+Extension.swift
//  CDL
//
//  Created by Сергей Никитин on 05.08.2022.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
