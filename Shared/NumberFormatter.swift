//
//  NumberFormatter.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 9/2/21.
//

import Foundation

extension NumberFormatter {
    static var currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        return formatter
    }()

    static var currencyInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""
        return formatter
    }()

    static var decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
