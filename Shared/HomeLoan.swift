//: A UIKit based Playground for presenting user interface

import SwiftUI

class HomeLoan: ObservableObject {
    let loanAmount: Double
    let duration: Int
    let interestType: InterestType

    var multiplier: Int { repaymentFrequency.rawValue }

    var totalInterest: Double = 0
    var totalRepayments: Double = 0

    private(set) var normalRepaymentsTable: [TableGroup] = []
    private(set) var extraRepaymentsTable: [TableGroup] = []

    var standardRepayment: Double {
        switch interestType {
        case .standard(let rate):
            return Calculator.calculatePayment(on: loanAmount, over: duration, at: rate, frequency: repaymentFrequency)
        case .fixedPeriod(let fixedInterest):
            let balance = Calculator.calculateRemainingBalanceAfter(period: fixedInterest.duration, on: loanAmount, over: 30, at: fixedInterest.fixedRate, frequency: repaymentFrequency)
            return Calculator.calculatePayment(on: balance, over: duration - fixedInterest.duration, at: fixedInterest.variableRate, frequency: repaymentFrequency)
        }
    }

    var fixedPeriodRepayment: Double? {
        switch interestType {
        case .standard:
            return nil
        case .fixedPeriod(let fixedInterest):
            return Calculator.calculatePayment(on: loanAmount, over: duration, at: fixedInterest.fixedRate, frequency: repaymentFrequency)
        }
    }

    var repaymentFrequency: RepaymentFrequency = .monthly {
        didSet {
            updateExtraAmortizationTable()
            objectWillChange.send()
        }
    }

    var extraRepayment: Double? {
        didSet {
            updateExtraAmortizationTable()
            objectWillChange.send()
        }
    }

    var table: [TableGroup] {
        extraRepaymentsTable.isEmpty ? normalRepaymentsTable : extraRepaymentsTable
    }
    
    init(loanAmount: Double, duration: Int, repayment: InterestType) {
        self.loanAmount = loanAmount
        self.duration = duration
        self.interestType = repayment
        updateNormalAmortizationTable()
    }

    private func updateNormalAmortizationTable() {
        let table = Self.makeAmortizationTable(loanAmount: loanAmount, duration: duration, repayment: interestType, frequency: repaymentFrequency)
        totalInterest = table.reduce(0) { $0 + $1.interest }
        totalRepayments = table.reduce(0) { $0 + $1.repayment }
        normalRepaymentsTable = table
    }

    private func updateExtraAmortizationTable() {
        let table = Self.makeAmortizationTable(loanAmount: loanAmount, duration: duration, repayment: interestType, frequency: repaymentFrequency, extraRepayment: extraRepayment)
        totalInterest = table.reduce(0) { $0 + $1.interest }
        totalRepayments = table.reduce(0) { $0 + $1.repayment }
        extraRepaymentsTable = table
    }
}

extension HomeLoan {
    static func makeAmortizationTable(loanAmount: Double, duration: Int, repayment: InterestType, frequency: RepaymentFrequency, extraRepayment: Double? = nil) -> [TableGroup] {
        switch repayment {
        case .standard(let interestRate):
            var payment = Calculator.calculatePayment(on: loanAmount, over: duration, at: interestRate, frequency: frequency)
            payment += extraRepayment ?? 0
            let table = createLoanTable(for: loanAmount, over: duration, at: interestRate, with: payment, frequency: frequency)
            return makeTable(fixed: table, frequency: frequency)

        case .fixedPeriod(let fixedInterest):
            let remainingTerm = duration - fixedInterest.duration


            var fixedPayment = Calculator.calculatePayment(on: loanAmount, over: duration, at: fixedInterest.fixedRate, frequency: frequency)
            fixedPayment += extraRepayment ?? 0

            let fixedTable = Array(createLoanTable(for: loanAmount, over: duration, at: fixedInterest.fixedRate, with: fixedPayment, frequency: frequency).prefix(fixedInterest.duration(for: frequency)))
            let balance = fixedTable.last!.closing

            var standardPayment = Calculator.calculatePayment(on: balance, over: remainingTerm, at: fixedInterest.variableRate, frequency: frequency)
            standardPayment += extraRepayment ?? 0

            let variableTable = createLoanTable(for: balance, over: remainingTerm, at: fixedInterest.variableRate, with: standardPayment, frequency: frequency, startIndex: fixedInterest.duration(for: frequency))

            return makeTable(fixed: fixedTable, variable: variableTable, frequency: frequency)
        }
    }

    private static func makeTable(fixed: [TableRow], variable: [TableRow] = [], frequency: RepaymentFrequency) -> [TableGroup] {
        var groups: [TableGroup] = []

        let multiplier = frequency.rawValue
        let fixedGroups = Int((Double(fixed.count) / multiplier.doubleValue).rounded(.up))
        for i in 0..<fixedGroups {
            var rows: [TableRow] = []

            let start: Int = (i * multiplier)
            var end: Int = start + multiplier - 1
            if end >= fixed.count {
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

        let variableGroups = Int((variable.count.doubleValue / multiplier.doubleValue).rounded(.up))
        for i in 0..<variableGroups {
            var rows: [TableRow] = []

            let start: Int = (i * multiplier)
            var end: Int = start + multiplier - 1
            if end >= variable.count {
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

    static func createLoanTable(for amount: Double, over duration: Int, at interestRate: Double, with repayment: Double, frequency: RepaymentFrequency, startIndex: Int = 0) -> [TableRow] {
        let rate = interestRate / frequency.rawValue.doubleValue / 100

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

struct FixedPeriodInterest {
    let duration: Int
    let fixedRate: Double
    let variableRate: Double

    func duration(for frequency: RepaymentFrequency) -> Int {
        duration * frequency.rawValue
    }
}

enum InterestType: Equatable, CustomStringConvertible {
    case standard(Double)
    case fixedPeriod(FixedPeriodInterest)

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

    static func == (lhs: InterestType, rhs: InterestType) -> Bool {
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

enum RepaymentFrequency: Int, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case monthly = 12
    case fortnightly = 26
    case weekly = 52

    var label: String {
        switch self {
        case .monthly: return "Monthly"
        case .fortnightly: return "Fortnightly"
        case .weekly: return "Weekly"
        }
    }
}
