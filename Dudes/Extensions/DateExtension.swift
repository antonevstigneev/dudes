//
//  DateExtension.swift
//  Dudes
//
//  Created by Anton Evstigneev on 16.12.2020.
//

import Foundation

extension Date {
 static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"

        return dateFormatter.string(from: Date())

    }
}
