//: A UIKit based Playground for presenting user interface

import SwiftUI

class HomeLoan: ObservableObject {
    let loanAmount: Double
    let duration: Int
    let repayment: Repayment

    var totalInterest: Double = 0
    var totalRepayments: Double = 0

    private(set) var normalRepaymentsTable: [TableGroup] = []
    private(set) var extraRepaymentsTable: [TableGroup] = []

    var standardRepayment: Double {
        switch repayment {
        case .standard(let interestRate):
            return Calculator.calculateMonthlyPayment(on: loanAmount, over: duration, at: interestRate)
        case .fixedPeriod(let repayment):
            let balance = Calculator.calculateRemainingBalanceAfter(period: repayment.duration, on: loanAmount, over: 30, at: repayment.fixedRate)
            return Calculator.calculateMonthlyPayment(on: balance, over: duration - repayment.duration, at: repayment.variableRate)
        }
    }

    var fixedPeriodRepayment: Double? {
        switch repayment {
        case .standard:
            return nil
        case .fixedPeriod(let repayment):
            return Calculator.calculateMonthlyPayment(on: loanAmount, over: duration, at: repayment.fixedRate)
        }
    }

    var extraRepayment: Double? {
        didSet {
            updateExtraAmortizationTable()
            objectWillChange.send()
        }
    }

    private var durationInMonths: Int { duration * 12 }

    var table: [TableGroup] {
        extraRepaymentsTable.isEmpty ? normalRepaymentsTable : extraRepaymentsTable
    }
    
    init(loanAmount: Double, duration: Int, repayment: Repayment) {
        self.loanAmount = loanAmount
        self.duration = duration
        self.repayment = repayment
        updateNormalAmortizationTable()
    }

    private func updateNormalAmortizationTable() {
        let table = Self.makeAmortizationTable(loanAmount: loanAmount, duration: duration, repayment: repayment)
        totalInterest = table.reduce(0) { $0 + $1.interest }
        totalRepayments = table.reduce(0) { $0 + $1.repayment }
        self.normalRepaymentsTable = table
    }

    private func updateExtraAmortizationTable() {
        let table = Self.makeAmortizationTable(loanAmount: loanAmount, duration: duration, repayment: repayment, extraRepayment: extraRepayment)
        totalInterest = table.reduce(0) { $0 + $1.interest }
        totalRepayments = table.reduce(0) { $0 + $1.repayment }
        self.extraRepaymentsTable = table
    }

    static func makeAmortizationTable(loanAmount: Double, duration: Int, repayment: Repayment, extraRepayment: Double? = nil) -> [TableGroup] {
        switch repayment {
        case .standard(let interestRate):
            var payment = Calculator.calculateMonthlyPayment(on: loanAmount, over: duration, at: interestRate)
            payment += extraRepayment ?? 0
            let table = createLoanTable(for: loanAmount, over: duration, at: interestRate, with: payment)
            return makeTable(fixed: table)

        case .fixedPeriod(let repayment):
            let balance = Calculator.calculateRemainingBalanceAfter(period: repayment.duration, on: loanAmount, over: duration, at: repayment.fixedRate)
            let remainingTerm = duration - repayment.duration


            var fixedPayment = Calculator.calculateMonthlyPayment(on: loanAmount, over: duration, at: repayment.fixedRate)
            fixedPayment += extraRepayment ?? 0

            var standardPayment = Calculator.calculateMonthlyPayment(on: balance, over: remainingTerm, at: repayment.variableRate)
            standardPayment += extraRepayment ?? 0


            let fixedTable = Array(createLoanTable(for: loanAmount, over: duration, at: repayment.fixedRate, with: fixedPayment).prefix(repayment.durationMonths))
            let variableTable = createLoanTable(for: balance, over: remainingTerm, at: repayment.variableRate, with: standardPayment, startIndex: repayment.durationMonths)

            return makeTable(fixed: fixedTable, variable: variableTable)
        }
    }

    private static func makeTable(fixed: [TableRow], variable: [TableRow] = []) -> [TableGroup] {
        var groups: [TableGroup] = []

        let fixedGroups = Int((Double(fixed.count) / 12.0).rounded(.up))
        for i in 0..<fixedGroups {
            var rows: [TableRow] = []

            let start: Int = (i * 12)
            var end: Int = start + 11
            if end > fixed.count {
                end = fixed.count - 1
            }
            rows.append(contentsOf: fixed[start...end])

            let interest = rows.reduce(0) { $0 + $1.interest }
            let repayment = rows.reduce(0) { $0 + $1.repayment }

            let openingBalance = rows[0].opening
            let closingBalance = rows.last?.closing ?? 0
            let group = TableGroup(id: i, opening: openingBalance, closing: closingBalance, interest: interest, repayment: repayment, rows: rows)

            groups.append(group)
        }

        let variableGroups = Int(variable.count / 12)
        for i in 0..<variableGroups {
            var rows: [TableRow] = []

            let start: Int = (i * 12)
            var end: Int = start + 11
            if end > variable.count {
                end = variable.count - 1
            }
            rows.append(contentsOf: variable[start...end])

            let interest = rows.reduce(0) { $0 + $1.interest }
            let repayment = rows.reduce(0) { $0 + $1.repayment }

            let openingBalance = rows.first!.opening
            let closingBalance = rows.last!.closing
            let group = TableGroup(id: i + fixedGroups, opening: openingBalance, closing: closingBalance, interest: interest, repayment: repayment, rows: rows)

            groups.append(group)
        }

        return groups
    }

    static func createLoanTable(for amount: Double, over duration: Int, at interestRate: Double, with repayment: Double, startIndex: Int = 0) -> [TableRow] {
        let rate = interestRate / 12 / 100

        var balance = amount
        var payment = repayment
        var index = startIndex + 1
        var table: [TableRow] = []

        while balance > 0 {
            let openingBalance = balance
            let interest = balance * rate
            let newBalance = balance + interest
            payment = min(newBalance, repayment)
            balance = newBalance - payment

            table.append(.init(id: index, opening: openingBalance, interest: interest, repayment: payment, closing: balance))
            index += 1
        }

        return table
    }
}

struct FixedPeriodRepayment {
    let duration: Int
    let fixedRate: Double
    let variableRate: Double

    var durationMonths: Int { duration * 12 }
}

enum Repayment: Equatable, CustomStringConvertible {
    case standard(Double)
    case fixedPeriod(FixedPeriodRepayment)

    var isValid: Bool {
        switch self {
        case .standard(let rate):
            return rate > 0
        case .fixedPeriod(let repayment):
            return repayment.duration > 0 &&
                repayment.fixedRate > 0 &&
                repayment.variableRate > 0
        }
    }

    var fixedPeriod: Int? {
        switch self {
        case .standard:
            return nil
        case .fixedPeriod(let term):
            return term.duration
        }
    }

    var fixedInterestRate: Double? {
        switch self {
        case .standard:
            return nil
        case .fixedPeriod(let term):
            return term.fixedRate
        }
    }

    var standardInterestRate: Double {
        switch self {
        case .standard(let rate):
            return rate
        case .fixedPeriod(let term):
            return term.variableRate
        }
    }

    static func == (lhs: Repayment, rhs: Repayment) -> Bool {
        switch (lhs, rhs) {
        case (.standard(let l), .standard(let r)):
            return l == r

        case (.fixedPeriod(let l), .fixedPeriod(let r)):
            return l.duration == r.duration && l.fixedRate == r.fixedRate && l.variableRate == r.variableRate

        default:
            return false
        }
    }

    var description: String {
        switch self {
        case .standard(let rate):
            return "\(rate)% per annum"
        case .fixedPeriod(let repayment):
            return "\(repayment.fixedRate)% for \(repayment.duration) years then \(repayment.variableRate)% per annum"
        }
    }
}
