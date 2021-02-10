//
//  Double.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 9/2/21.
//

import Foundation

extension Double {
    var currencyString: String {

        return NumberFormatter.currency.string(from: NSNumber(value: self)) ?? ""
    }

    var percentageString: String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.minimumFractionDigits = 2
            return formatter
        }()


        return formatter.string(from: NSNumber(value: self / 100)) ?? ""
    }

    func round(to places: Int) -> Double {
            let divisor = pow(10.0, Double(places))
            return (self * divisor).rounded() / divisor
    }

    func roundUp(to places: Int) -> Double {
            let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(.up) / divisor
    }
}
