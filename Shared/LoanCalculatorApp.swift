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
//            ContentView(loan: .init(loanAmount: 650000, term: .fixed(FixedTerm(duration: 30, rate: 1.99))))
//            ContentView(loan: .init(loanAmount: 650000, term: .mix(.init(totalDuration: 30, fixedDuration: 4, fixedRate: 1.99, variableRate: 3.85))))
        }
    }
}
