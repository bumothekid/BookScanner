//
//  Extensions.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import Foundation
import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UIColor {
    static let backgroundColor = UIColor(named: "backgroundColor")!
    static let secondaryBackgroundColor = UIColor(named: "secondaryBackgroundColor")!
}

extension Formatter {
    static let all: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    func customStringToDate(string: String) -> Date? {
        if let date = Formatter.all.date(from: string) ?? Formatter.monthYear.date(from: string) ?? Formatter.year.date(from: string) {
            return date
        }
        
        return nil
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let customStringToDate = custom {
            let container = try $0.singleValueContainer()
            let string = try container.decode(String.self)
        
            if let date = Formatter.all.date(from: string) ?? Formatter.monthYear.date(from: string) ?? Formatter.year.date(from: string) {
                return date
            }
        
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
}

extension String {
    func generateStringSequence() -> [String] {
        guard self.count > 0 else { return [String]() }
        
        var sequences = [String]()
        
        for i in 1...self.count {
            sequences.append(String(self.prefix(i)))
        }
        
        return sequences
    }
}
