//
//  LoanCalculatorApp.swift
//  Shared
//
//  Created by Gagandeep Singh on 2/2/21.
//

import SwiftUI

@main
struct LoanCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            HomeLoanForm()
//            ContentView(loan: .init(loanAmount: 650000, duration: 30, repayment: .standard(1.99)))
//            ContentView(loan: .init(loanAmount: 650000, duration: 30, repayment: .fixedPeriod(.init(duration: 4, fixedRate: 1.99, variableRate: 3.85))))
        }
    }
}
