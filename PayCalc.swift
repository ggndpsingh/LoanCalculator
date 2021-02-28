////
////  PayCalc.swift
////  LoanCalculator (iOS)
////
////  Created by Gagandeep Singh on 27/2/21.
////
//import Foundation
//
//import { preBudget2020 } from './calculatorData'
//import {
//    currentTaxData,
//    setTaxData,
//    payOptions,
//    FREQUENCY_DAILY,
//    FREQUENCY_HOURLY,
//    PRORATA_LIMITS,
//    OVERTIME_TYPE_HOURLY,
//} from '../state/calculatorState'
//
//import {
//    roundToNearestCent,
//    roundToNearestDollar,
//    formatMoney,
//} from '../utils/utils';
//import { SCALE2, SCALE6 } from '../constants';
//
//
//
////-----------------------------------------------------
//// Constants
////-----------------------------------------------------
//
//const state = () => Calculator.state;
//// const day2Year = 365;
//let week2Year = 52;
//// const week2YearExtra = 53;
//let fortnight2Year = 26;
//// const fortnight2YearExtra = 27;
//let day2Week = 5;
//let month2Year = 12;
//let week2Month = week2Year / month2Year; //4.33
//let week2Fortnight = 2;
//
//
//
//// const ANNUALLY = 'annually';
//const WEELKY = 'weekly';
//const FORTNIGHTLY = 'fortnightly';
//const MONTHLY = 'monthly';
//
//
////-----------------------------------------------------
//// Tax Data
////-----------------------------------------------------
//let useLegacyTaxData = false;
//
//const TaxData = () => {
//    if (useLegacyTaxData) {
//        return preBudget2020;
//    }
//    return currentTaxData;
//}
//
//
//
////-----------------------------------------------------
//// Calculator
////-----------------------------------------------------
//export const Calculator = {
//    state: {},
//
//    setState: (obj) => {
//        Calculator.state = obj;
//        setTaxData(Calculator.state);
//        return Calculator;
//    },
//
//    isDebug: false,
//
//
//    ///////////////////////////////////////////
//    // RESET
//    ///////////////////////////////////////////
//    reset: () => {
//        zero(state().allowance);
//        zero(state().baseSalary);
//        zero(state().overtimeSalary);
//        zero(state().deductions);
//        zero(state().superannuation);
//        zero(state().superannuationReportable);
//        zero(state().superannuationSacrafice);
//        zero(state().totalSuperannuation);
//
//        zero(state().help);
//        zero(state().sfss);
//        zero(state().medicare);
//        zero(state().medicareAdjustment);
//        zero(state().offsets)
//        zero(state().extraWithholdingTax);
//
//        state().familyIncome = 0;
//        state().otherTaxesAndLevies = 0;
//        state().lito = 0;
//        state().lamito = 0;
//        state().mito = 0;
//        state().mawto = 0;
//        state().sapto = 0;
//        state().superannuationGuarantee = 0;
//        state().spouseSuperTaxOffset = 0;
//        state().superannuationConcessional = 0;
//        state().superannuationConcessionalTax = 0;
//        state().superannationTaxableNonConcessional = 0;
//        state().superannuationCoContribution = 0;
//        state().superannuationCoContributionNonConcessional = 0;
//
//        state().superannuationExcess = 0;
//        state().superannuationExcessTax = 0;
//        state().concessionalAdditionalSuper = 0;
//
//        state.adjustedTaxableIncome = 0;
//        state.adjustedAnnualTaxableIncome = 0;
//
//        state().incomeTaxWithheldMonthlyLegacy = 0;
//
//        state().medicareFamilyAdjustment = false;
//        // state().warnings.superannuationCapped = false;
//        // state().warnings.superannuation = [];
//
//        state().warnings = {
//            superannuation:[],
//            nonConcessionalCap: false,// over the limit
//            superannuationGuarantee: false, // under the guarantee
//            medicareSurcharge: false, // Over the limit if not private healthcare
//            division293: false, // additional tax on super outside fund
//            extraPayment: state().warnings.extraPayment,
//            maxSalarySacrafice: false,
//            superannuationCapped: false,
//          };
//
//
//        // not being used:
//
//        // reset ratios
//        week2Year = 52;
//        fortnight2Year = 26;
//        month2Year = 12;
//        week2Month = week2Year / month2Year; //4.33
//        week2Fortnight = 2;
//
//        return Calculator;
//    },
//
//
//    ///////////////////////////////////////////
//    // Income
//    ///////////////////////////////////////////
//    getIncome: () => {
//
//        const payCycle = payOptions[state().payOption].title.toLowerCase();
//
//
//        // check if there are additional weekly or fortnightly payments
//        if (payCycle === "fortnightly" && state().payments.f > 26) {
//            fortnight2Year = state().payments.f;
//        } else {
//            fortnight2Year = 26;
//        }
//
//        if (payCycle === "weekly" && state().payments.w > 52) {
//            week2Year = state().payments.w;
//        } else {
//            week2Year = 52;
//        }
//
//        // capture data in form field
//        switch (payCycle) {
//            case "annually":
//                state().baseSalary.a = getInputIncome();
//                //derived
//                state().baseSalary.m = state().baseSalary.a / month2Year;
//                state().baseSalary.f = state().baseSalary.a / fortnight2Year;
//                state().baseSalary.w = state().baseSalary.a / week2Year;
//                break;
//
//            case "monthly":
//                state().baseSalary.m = getInputIncome();
//                //derived
//                state().baseSalary.a = state().baseSalary.m * month2Year;
//                state().baseSalary.f = state().baseSalary.a / fortnight2Year;
//                state().baseSalary.w = state().baseSalary.a / week2Year;
//                break;
//            case "fortnightly":
//
//                state().baseSalary.f = getInputIncome();
//                state().baseSalary.w = state().baseSalary.f / week2Fortnight;
//                state().baseSalary.m = state().baseSalary.w * week2Month;
//                //derived
//                state().baseSalary.a = state().baseSalary.f * fortnight2Year;
//
//
//                break;
//            case "weekly":
//                state().baseSalary.w = getInputIncome();
//                state().baseSalary.f = state().baseSalary.w * week2Fortnight;
//                state().baseSalary.m = state().baseSalary.w * week2Month;
//                // derived
//                state().baseSalary.a = state().baseSalary.w * week2Year;
//
//
//
//                break;
//            case "daily":
//                //casualDaily
//                if (state().casualDaily.frequency === FREQUENCY_DAILY[0]) {
//                    // Days per week
//                    state().baseSalary.w = getInputIncome() * state().casualDaily.days;
//                    state().baseSalary.f = state().baseSalary.w * week2Fortnight;
//                    state().baseSalary.m = state().baseSalary.w * week2Month;
//
//                    state().baseSalary.a = state().baseSalary.w * week2Year;
//
//                    // adjust annual amount
//                    state().baseSalary.a = Number(state().casualDaily.annual) * state().baseSalary.w;
//                }
//
//                if (state().casualDaily.frequency === FREQUENCY_DAILY[1]) {
//                    // Days per fortnight
//                    state().baseSalary.f = getInputIncome() * state().casualDaily.days;
//                    state().baseSalary.w = state().baseSalary.f / week2Fortnight;
//                    state().baseSalary.m = state().baseSalary.w * week2Month;
//
//                    state().baseSalary.a = state().baseSalary.f * fortnight2Year;
//
//                    // adjust annual amount
//                    state().baseSalary.a = Number(state().casualDaily.annual) * state().baseSalary.f;
//                }
//
//                if (state().casualDaily.frequency === FREQUENCY_DAILY[2]) {
//                    // Days per month
//                    state().baseSalary.m = getInputIncome() * state().casualDaily.days;
//                    state().baseSalary.a = state().baseSalary.a * month2Year;
//                    state().baseSalary.f = state().baseSalary.a / fortnight2Year;
//                    state().baseSalary.w = state().baseSalary.a / week2Year;
//
//                    // adjust annual amount
//                    state().baseSalary.a = Number(state().casualDaily.annual) * state().baseSalary.m;
//                }
//
//                if (state().casualDaily.frequency === FREQUENCY_DAILY[3]) {
//                    // Days per year
//                    state().baseSalary.a = getInputIncome() * state().casualDaily.days;
//                    state().baseSalary.m = state().baseSalary.a / month2Year;
//                    state().baseSalary.f = state().baseSalary.a / fortnight2Year;
//                    state().baseSalary.w = state().baseSalary.a / week2Year;
//                }
//                //
//
//                break;
//
//            case "hourly":
//                //casualHourly
//
//                if (state().casualHourly.frequency === FREQUENCY_HOURLY[0]) {
//                    // Hours per week
//                    state().baseSalary.w = getInputIncome() * Number(state().casualHourly.hours);
//                    state().baseSalary.f = state().baseSalary.w * week2Fortnight;
//                    state().baseSalary.m = state().baseSalary.w * week2Month;
//                    //state().baseSalary.a = state().baseSalary.w * week2Year;
//
//                    // adjust annual amount
//                    state().baseSalary.a = Number(state().casualHourly.annual) * state().baseSalary.w;
//
//                }
//
//                if (state().casualHourly.frequency === FREQUENCY_HOURLY[1]) {
//                    // Hours per fortnight
//                    state().baseSalary.f = getInputIncome() * state().casualHourly.hours
//                    state().baseSalary.w = state().baseSalary.f / week2Fortnight;
//                    state().baseSalary.m = state().baseSalary.w * week2Month;
//
//                    // state().baseSalary.a = state().baseSalary.f * fortnight2Year;
//                    // adjust annual amount
//                    state().baseSalary.a = Number(state().casualHourly.annual) * state().baseSalary.f;
//                }
//
//                if (state().casualHourly.frequency === FREQUENCY_HOURLY[2]) {
//                    // Hours per month
//                    state().baseSalary.m = getInputIncome() * state().casualHourly.hours
//                    state().baseSalary.a = state().baseSalary.a * month2Year;
//                    state().baseSalary.f = state().baseSalary.a / fortnight2Year;
//                    state().baseSalary.w = state().baseSalary.a / week2Year;
//
//                    // adjust annual amount
//                    state().baseSalary.a = Number(state().casualHourly.annual) * state().baseSalary.m;
//                }
//
//                if (state().casualHourly.frequency === FREQUENCY_HOURLY[3]) {
//                    // Days per year
//                    state().baseSalary.a = getInputIncome() * state().casualHourly.hours
//                    state().baseSalary.m = state().baseSalary.a / month2Year;
//                    state().baseSalary.f = state().baseSalary.a / fortnight2Year;
//                    state().baseSalary.w = state().baseSalary.a / week2Year;
//
//                }
//                break;
//
//            default:
//                break;
//        }
//
//        // base income off base Salary
//        state().income.a = state().baseSalary.a;
//        state().income.m = state().baseSalary.m;
//        state().income.f = state().baseSalary.f;
//        state().income.w = state().baseSalary.w;
//
//        if (Calculator.isDebug) console.log("Get Income -> Base Salary: ", state().baseSalary)
//
//        // set ratios
//        week2Year = state().baseSalary.a / state().baseSalary.w | week2Year;
//        fortnight2Year = state().baseSalary.a / state().baseSalary.f | fortnight2Year;
//        month2Year = state().baseSalary.a / state().baseSalary.m | month2Year;
//        week2Month = week2Year / month2Year | week2Month;
//        week2Fortnight = 2;
//
//
//        return Calculator;
//
//    },
//
//
//    ///////////////////////////////////////////
//    // ProRata
//    ///////////////////////////////////////////
//    calculateProRata: () => {
//
//        // only if fulltime
//        const fulltime = payOptions[state().payOption].type === "fulltime";
//
//        if (fulltime && state().adjustProRata) {
//            state().proRataPercent = state().proRataAmount / PRORATA_LIMITS[state().proRataAmountFrequency][state().proRataFrequency];
//
//            state().income.a *= state().proRataPercent;
//            state().income.m *= state().proRataPercent;
//            state().income.f *= state().proRataPercent;
//            state().income.w *= state().proRataPercent;
//
//
//            state().baseSalary.a *= state().proRataPercent;
//            state().baseSalary.m *= state().proRataPercent;
//            state().baseSalary.f *= state().proRataPercent;
//            state().baseSalary.w *= state().proRataPercent;
//
//        } else {
//            state().proRataPercent = 1;
//        }
//
//        return Calculator;
//    },
//
//
//    ///////////////////////////////////////////
//    // OVERTIME
//    ///////////////////////////////////////////
//    calculateOvertime: () => {
//        let overtimePerWeek = 0;
//        let overtimePerFortnight = 0;
//        let overtimePerMonth = 0;
//        let overtimePerYear = 0;
//
//        state().overtime.map(ot => {
//            if (!ot) return Calculator;
//            let hourlyRate = 0;
//            if (ot.type === OVERTIME_TYPE_HOURLY) {
//                hourlyRate = ot.hourlyRate;
//            } else {
//                // refer back to the primary hourly rate
//                hourlyRate = state().salary * ot.loadingRate;
//            }
//            // FREQUENCY_HOURLY and FREQUENCY_DAILY are the same;
//
//            if (ot.frequency === FREQUENCY_HOURLY[0]) {
//                // hours per week
//                overtimePerWeek = ot.hours * hourlyRate;
//                overtimePerFortnight = overtimePerWeek * week2Fortnight;
//                overtimePerMonth = overtimePerWeek * week2Month;
//
//                overtimePerYear = ot.annualFrequency * (ot.hours * hourlyRate); // (weeks per year)
//
//                console.log("Overtimr per week:", overtimePerWeek, hourlyRate, ot.hours, ot.type);
//
//
//            } else if (ot.frequency === FREQUENCY_HOURLY[1]) {
//                // hours per ft
//                overtimePerFortnight = (ot.hours * hourlyRate);
//                overtimePerWeek = overtimePerFortnight / week2Fortnight
//                overtimePerMonth = overtimePerWeek * week2Month;
//
//                overtimePerYear = ot.annualFrequency * (ot.hours * hourlyRate);
//
//
//            } else if (ot.frequency === FREQUENCY_HOURLY[2]) {
//                // hours per month
//                overtimePerMonth = (ot.hours * hourlyRate);
//                overtimePerWeek = overtimePerMonth / week2Month;
//                overtimePerFortnight = overtimePerWeek * week2Fortnight
//
//                overtimePerYear = ot.annualFrequency * (ot.hours * hourlyRate);
//
//            } else if (ot.frequency === FREQUENCY_HOURLY[3]) {
//                // hours per year
//                overtimePerYear = ot.annualFrequency * (ot.hours * hourlyRate);
//
//
//                overtimePerWeek = overtimePerYear / week2Year;
//                overtimePerFortnight = overtimePerWeek * week2Fortnight;
//                overtimePerMonth = overtimePerWeek * week2Month;
//            }
//
//            // add overtime to total overtime
//            state().overtimeSalary.w += overtimePerWeek;
//            state().overtimeSalary.f += overtimePerFortnight
//            state().overtimeSalary.m += overtimePerMonth
//            state().overtimeSalary.a += overtimePerYear;
//
//            // return Calculator;
//        })
//
//        // Add overtime per week to income
//        // state().overtimeSalary.w = overtimePerWeek;
//        // state().overtimeSalary.f = overtimePerWeek * week2Fortnight;
//        // state().overtimeSalary.m = (overtimePerWeek * week2Year) / month2Year;
//
//
//        // state().overtimeSalary.a = overtimePerYear;
//
//        state().income.w += state().overtimeSalary.w;
//        state().income.f += state().overtimeSalary.f;
//        state().income.a += state().overtimeSalary.a;
//        state().income.m += state().overtimeSalary.m;
//
//        return Calculator;
//    },
//
//
//    ///////////////////////////////////////////
//    // Allowances
//    ///////////////////////////////////////////
//    calculateAllowances: () => {
//
//        // Allowances
//        if (state().adjustAllowanceIncome === true) {
//            switch (Number(state().allowanceIncomeOption)) {
//                case 0:
//                    // annual
//                    // add income to annual amount only
//                    state().allowance.a = Number(state().allowanceIncome);
//                    break;
//
//                case 1:
//                    // month
//                    state().allowance.m = Number(state().allowanceIncome);
//                    state().allowance.a = month2Year * Number(state().allowanceIncome);
//                    break;
//
//                case 2:
//                    // fortnight
//                    state().allowance.f = Number(state().allowanceIncome);
//                    state().allowance.m = (fortnight2Year * Number(state().allowanceIncome)) / month2Year;
//                    state().allowance.a = fortnight2Year * Number(state().allowanceIncome);
//                    break;
//
//                case 3:
//                    // week
//                    state().allowance.w = Number(state().allowanceIncome);
//                    state().allowance.f = week2Fortnight * Number(state().allowanceIncome);
//                    state().allowance.m = week2Month * Number(state().allowanceIncome);
//                    state().allowance.a = week2Year * Number(state().allowanceIncome);
//                    break;
//                default:
//                    break;
//            }
//
//            // add allowance to income
//            state().income.w += state().allowance.w;
//            state().income.f += state().allowance.f;
//            state().income.m += state().allowance.m;
//            state().income.a += state().allowance.a;
//        }
//
//        return Calculator;
//
//    },
//
//
//    ///////////////////////////////////////////
//    // Superannuation Salary sacrafice
//    ///////////////////////////////////////////
//    calculateSalarySacrafice: () => {
//        //reset
//        // state().salaryScaracficeAmount = 0;
//        let limit = Number.MAX_SAFE_INTEGER;
//        if (TaxData().superannuation && TaxData().superannuation.concessionalCap !== undefined) {
//            limit = TaxData().superannuation.concessionalCap - state().superannuation.a;
//        } else {
//            console.log("No 'superannuation.concessionalCap' data")
//        }
//
//        if (limit < 0) limit = 0;
//
//        // inline check to limit sacrafice super to concessional limit
//        const limitSalarySacrafice = state().capSuperannaution;
//        if (!limitSalarySacrafice) {
//            limit = Number.MAX_SAFE_INTEGER;
//        }
//
//        // ensure salary sacrafice values are within the income range
//        if (state().adjustSalaryScaracfice) {
//
//            if (state().salaryScaracficeAmount < 0) { state().salaryScaracficeAmount = 0 }
//            switch (Number(state().salarySacraficeOption)) {
//                case 0:
//                    // year
//                    //state().salaryScaracficeAmount = Math.min(state().salaryScaracficeAmount, state().income.a);
//
//                    if (state().salaryScaracficeAmount > limit) {
//                        state().salaryScaracficeAmount = limit;
//                    }
//
//                    state().superannuationSacrafice.a = state().salaryScaracficeAmount;
//                    break;
//                case 1:
//                    // month
//                    //state().salaryScaracficeAmount = Math.min(state().salaryScaracficeAmount, state().income.m);
//                    state().superannuationSacrafice.a = Math.min(limit, state().salaryScaracficeAmount * month2Year);
//                    state().salaryScaracficeAmount = state().superannuationSacrafice.a / month2Year;
//                    break;
//                case 2:
//                    // fortnight
//                    //state().salaryScaracficeAmount = Math.min(state().salaryScaracficeAmount, state().income.f);
//                    state().superannuationSacrafice.a = Math.min(limit, state().salaryScaracficeAmount * fortnight2Year);
//                    state().salaryScaracficeAmount = state().superannuationSacrafice.a / fortnight2Year;
//                    break;
//                case 3:
//                    // week
//                    //state().salaryScaracficeAmount = Math.min(state().salaryScaracficeAmount, state().income.w);
//                    state().superannuationSacrafice.a = Math.min(limit, state().salaryScaracficeAmount * week2Year);
//                    state().salaryScaracficeAmount = state().superannuationSacrafice.a / week2Year;
//                    break;
//                case 4:
//                    // percent
//                    // reset if the value is > 100
//                    //state().salaryScaracficeAmount = state().salaryScaracficeAmount > 100 ? 0 : state().salaryScaracficeAmount;
//
//                    state().superannuationSacrafice.a = state().income.a * (state().salaryScaracficeAmount / 100);
//                    state().superannuationSacrafice.a = Math.min(limit, state().superannuationSacrafice.a);
//                    state().salaryScaracficeAmount = state().superannuationSacrafice.a * 100 / state().income.a
//                    break;
//                default:
//                    break;
//
//            }
//
//            // spread the amounts
//            spreadAnnualAmounts(state().superannuationSacrafice);
//        } else {
//            // reset
//            state().superannuationSacrafice.a = 0;
//            spreadAnnualAmounts(state().superannuationSacrafice);
//        }
//
//        // if this is in addition to income, deduct it from baseSalary
//        if (state().adjustSalaryScaracfice) {
//            state().income.a -= Number(state().superannuationSacrafice.a);
//            state().income.m -= Number(state().superannuationSacrafice.m);
//            state().income.f -= Number(state().superannuationSacrafice.f);
//            state().income.w -= Number(state().superannuationSacrafice.w);
//        }
//
//        state().warnings.maxSalarySacrafice = (state().salaryScaracficeAmount >= state().income.a);
//
//        if (Calculator.isDebug) console.log("calculateSalarySacrafice:", state().superannuationSacrafice)
//
//        return Calculator;
//    },
//
//
//
//
//    ///////////////////////////////////////////
//    // Superannuation (Superannuation guarantee)
//    ///////////////////////////////////////////
//    calculateSuperannuationGuarantee: () => {
//        /// ANYTHINBG OVER STANDARD RATE IS SALARY SACRAFICED ////
//
//        // adjusted rate
//        let guaranteeRate = Number(TaxData().superannuation.rate);
//        const userRate = state().adjustSuperannuationRate ? Number(state().superannuationRate) : guaranteeRate;
//
//        let reportableRate = 0;
//        let superannuationReportable = 0;
//
//        if (userRate > guaranteeRate) {
//            reportableRate = userRate - guaranteeRate;
//        }else{
//            guaranteeRate = userRate;
//        }
//
//        if (state().noSuperannuation) {
//            return Calculator;
//        }
//
//        // -------------------------
//        // Calculate 'Super Income'
//        // Not great - need to define Super income as it can vary from base Income depending on inputs (salary sacrafice)
//        // Super guarentee is based on ordinary hours
//        const superIncome = {
//            a: state().baseSalary.a,
//            m: state().baseSalary.m,
//            f: state().baseSalary.f,
//            w: state().baseSalary.w,
//        }
//
//        // re-apply pro rate to base income
//        // if (state().proRataPercent !== 1) {
//        //     superIncome.a *= state().proRataPercent;
//        //     superIncome.m *= state().proRataPercent;
//        //     superIncome.f *= state().proRataPercent;
//        //     superIncome.w *= state().proRataPercent;
//        // }
//
//        // apply allowances - these are part of Ordinary hours
//        if (state().allowance.a !== 0) {
//            superIncome.a += state().allowance.a;
//            superIncome.m += state().allowance.m;
//            superIncome.f += state().allowance.f;
//            superIncome.w += state().allowance.w;
//        }
//        // -------------------------
//
//        if (state().includesSuperannuation) {
//            // calculate the superannuation annually
//
//            state().superannuationGuarantee = getSuperannuation(superIncome.a, true, guaranteeRate);
//
//            if (reportableRate > 0) {
//                superannuationReportable = getSuperannuation(superIncome.a, true, reportableRate);
//                state().superannuationReportable.a += superannuationReportable;
//                state().superannuationReportable.m += superannuationReportable / month2Year;
//                state().superannuationReportable.f += superannuationReportable / fortnight2Year;
//                state().superannuationReportable.w += superannuationReportable / week2Year;
//            }
//
//            state().superannuation.a = state().superannuationGuarantee;
//
//            // calcualte the individual rates ( as factors of annual values)
//            state().superannuation.m = getSuperannuation(superIncome.m * month2Year, true, guaranteeRate) / month2Year;
//            state().superannuation.f = getSuperannuation(superIncome.f * fortnight2Year, true, guaranteeRate) / fortnight2Year;
//            state().superannuation.w = getSuperannuation(superIncome.w * week2Year, true, guaranteeRate) / week2Year;
//
//            // subtract assessable Income
//            state().income.a -= state().superannuation.a;
//            state().income.m -= state().superannuation.m;
//            state().income.f -= state().superannuation.f;
//            state().income.w -= state().superannuation.w;
//
//            state().income.a -= state().superannuationReportable.a;
//            state().income.m -= state().superannuationReportable.m;
//            state().income.f -= state().superannuationReportable.f;
//            state().income.w -= state().superannuationReportable.w;
//
//            // subtract from base Income
//            state().baseSalary.a -= state().superannuation.a;
//            state().baseSalary.m -= state().superannuation.m;
//            state().baseSalary.f -= state().superannuation.f;
//            state().baseSalary.w -= state().superannuation.w;
//
//            state().baseSalary.a -= state().superannuationReportable.a;
//            state().baseSalary.m -= state().superannuationReportable.m;
//            state().baseSalary.f -= state().superannuationReportable.f;
//            state().baseSalary.w -= state().superannuationReportable.w;
//
//
//        } else {
//
//            state().superannuationGuarantee = getSuperannuation(superIncome.a, false, guaranteeRate);
//            state().superannuation.a = state().superannuationGuarantee;
//
//            if (reportableRate > 0) {
//                superannuationReportable = getSuperannuation(superIncome.a, false, reportableRate);
//                state().superannuationReportable.a += superannuationReportable;
//                state().superannuationReportable.m += superannuationReportable / month2Year;
//                state().superannuationReportable.f += superannuationReportable / fortnight2Year;
//                state().superannuationReportable.w += superannuationReportable / week2Year;
//            }
//
//            // calcualte the individual rates ( by bumping up to annual values)
//            state().superannuation.m = getSuperannuation(superIncome.m * month2Year, false, guaranteeRate) / month2Year;
//            state().superannuation.f = getSuperannuation(superIncome.f * fortnight2Year, false, guaranteeRate) / fortnight2Year;
//            state().superannuation.w = getSuperannuation(superIncome.w * week2Year, false, guaranteeRate) / week2Year;
//
//        }
//
//        return Calculator;
//    },
//
//
//
//
//    ///////////////////////////////////////////
//    // Superannuationm Co-Contribution
//    ///////////////////////////////////////////
//    // ref: https://www.ato.gov.au/Calculators-and-tools/Host/?anchor=SuperCoContributions&anchor=SuperCoContributions#SuperCoContributions/questions
//
//    // Additional super incentive - must be non concessional
//    calculateSuperannuationCoContribution: () => {
//
//        if (TaxData().superannuationCocontribution === undefined) {
//            console.log("No 'superannuationCoContribution' data")
//            return Calculator;
//        }
//
//        const min = TaxData().superannuationCocontribution.minIncome;
//        const max = TaxData().superannuationCocontribution.maxIncome;
//        const contribution = state().adjustSuperannuation ? state().additionalSuper : 0;
//
//
//        let reportableIncome = state().baseSalary.a;
//        if (state().adjustSalaryScaracfice) {
//            reportableIncome += Number(state().superannuationSacrafice.a);
//        }
//
//        if (state().adjustOtherIncome === true) {
//            reportableIncome += Number(state().otherIncome);
//        }
//
//        if (state().adjustAllowanceIncome === true) {
//            reportableIncome += Number(state().allowance.a);
//        }
//
//        if (state().adjustDeductions === true) {
//            reportableIncome -= Number(state().taxableDeductions);
//        }
//
//        if (state().adjustFringeBenefits === true) {
//            reportableIncome += Number(state().fringeBenefits);
//        }
//        // Eligibility
//        state().superannuationCoContributionAvailable = (reportableIncome < max && state().superannuationExcess <= 0 && !state().over71 && !state().backpacker);
//
//
//        // Eligibility
//        if (state().superannuationCoContributionAvailable && contribution > 0 && state().superannuationCoContributionApply) {
//
//            const reductionFactor = TaxData().superannuationCocontribution.reductionFactor;
//            const maxEntitlement = TaxData().superannuationCocontribution.maxEntitlement;
//            const contributionRate = TaxData().superannuationCocontribution.contributionRate;
//            const minContribution = TaxData().superannuationCocontribution.minContribution;
//
//
//            // Co contribution calculation
//            let coContribution = maxEntitlement - (reductionFactor * (reportableIncome - min));
//
//            // Less than maximum contribution amount
//            coContribution = Math.min(maxEntitlement, coContribution);
//
//            // lesset of 50% contribution or co contribution
//            coContribution = Math.min(coContribution, contribution * contributionRate);
//            // minContribution amount
//            coContribution = Math.max(minContribution, coContribution);
//            state().superannuationCoContribution = roundToNearestDollar(coContribution);
//
//            // assign this as non concessional super
//            state().superannuationCoContributionNonConcessional = Math.min(1000, contribution);
//        }
//
//
//        return Calculator;
//    },
//
//
//
//
//    calculateTotalSuperannuation: () => {
//        // add up all the superannuation benefits and guarentees and contributions
//        state().totalSuperannuation = { ...state().superannuation }
//
//        // state().totalSuperannuation.a += Number(state().superannuationCoContribution);
//
//        //if (state().adjustSalaryScaracfice) {
//        // employer contributions
//        state().totalSuperannuation.a += Number(state().superannuationSacrafice.a);
//        state().totalSuperannuation.m += Number(state().superannuationSacrafice.m);
//        state().totalSuperannuation.f += Number(state().superannuationSacrafice.f);
//        state().totalSuperannuation.w += Number(state().superannuationSacrafice.w);
//
//        state().totalSuperannuation.a += Number(state().superannuationReportable.a);
//        state().totalSuperannuation.m += Number(state().superannuationReportable.m);
//        state().totalSuperannuation.f += Number(state().superannuationReportable.f);
//        state().totalSuperannuation.w += Number(state().superannuationReportable.w);
//
//
//        // // Co-contribution
//        // state().totalSuperannuation.a += Number(state().superannuationCoContribution);
//
//
//
//        //}
//
//        // if (state().adjustSuperannuation) {
//        //     // employee contributions
//        //     // state().totalSuperannuation.a += Number(state().additionalSuper);
//        // }
//
//
//        // Prepare the values used to split concessional and non concessional
//        const fundContributionCapMultiplier = state().over65 ? 1 : 3;
//        let nonConcesssionalCap = 0;
//        let concessionalCap = 0;
//        let concessionalTax = 0;
//        let nonConcessionalExcessTax = 0;
//        if (TaxData().superannuation &&
//            TaxData().superannuation.nonConcesssionalCap !== undefined &&
//            TaxData().superannuation.concessionalCap !== undefined &&
//            TaxData().superannuation.concessionalTax !== undefined &&
//            TaxData().superannuation.nonConcessionalExcessTax !== undefined
//        ) {
//            nonConcesssionalCap = TaxData().superannuation.nonConcesssionalCap;
//            concessionalCap = TaxData().superannuation.concessionalCap;
//            concessionalTax = TaxData().superannuation.concessionalTax;
//            nonConcessionalExcessTax = TaxData().superannuation.nonConcessionalExcessTax;
//
//        } else {
//            console.log("No 'superannuation.cap...' data", TaxData().superannuation.cap)
//        }
//        const fundContributionCap = nonConcesssionalCap * fundContributionCapMultiplier
//        const nonConcessionalCap = fundContributionCap;//TaxData().superannuation.nonConcesssionalCap;
//
//        // calculate concessional cap with carry forward amounts
//
//        if (TaxData().superannuationCarryForward !== undefined && state().adjustSuperannuationCarryForward) {
//            concessionalCap += Number(state().superannuationCarryForward);
//        }
//
//        // reset all categories
//        state().superannuationConcessional = 0;
//        state().superannuationConcessionalTax = 0;
//        state().superannationNonConcessional = 0;
//        state().superannuationExcess = 0;
//        state().superannuationExcessTax = 0;
//        state().superannationConcessionalRemaining = concessionalCap;
//        state().superannationNonConcessionalRemaining = nonConcessionalCap;
//        state().superannationTax = 0;
//
//
//        // Split the super into concessinal and non concesisonal buckets
//        // Make sure co-contribution amount is not concessional
//
//        // Super base concessionalCap Warning
//        if (state().superannuation.a >= concessionalCap) {
//            // Super guarntee has been capped
//            state().warnings.superannuation.push("Your base superannuation guarantee exceeds the limit of $" + formatMoney(concessionalCap, 0));
//        }
//
//        if (state().totalSuperannuation.a <= concessionalCap) {
//            // all super is concessional
//            state().superannuationConcessional = state().totalSuperannuation.a;
//
//        } else if (state().totalSuperannuation.a <= (nonConcessionalCap + concessionalCap)) {
//            // max out concessional and add remainder to non concessional
//            state().superannuationConcessional = concessionalCap
//            state().superannationNonConcessional = state().totalSuperannuation.a - concessionalCap;
//            state().warnings.superannuation.push("You have non-concessional superannuation of $" + formatMoney(state().superannationNonConcessional, 0));
//        } else {
//
//            // excess super
//            state().superannuationConcessional = concessionalCap
//            state().superannationNonConcessional = nonConcessionalCap;
//            state().superannuationExcess = state().totalSuperannuation.a - concessionalCap - nonConcessionalCap;
//            state().warnings.superannuation.push("You have an excess of non-concessional superannuation of $" + formatMoney(state().superannuationExcess, 0));
//        }
//
//        // remaining concessional
//        state().superannationConcessionalRemaining = concessionalCap - state().superannuationConcessional;
//
//        // capture nonconcessional super (sacraficed) before calculating personal contributions
//        state().superannuationUntaxedNonConcessional = state().superannationNonConcessional;
//
//        // Co-contribution adjustment
//        // state().superannationNonConcessional += state().superannuationCoContributionNonConcessional;
//
//
//        // Calculate concession on personal contributions
//        if (state().adjustSuperannuation) {
//            state().concessionalAdditionalSuper = Math.min(state().superannationConcessionalRemaining, (state().additionalSuper - state().superannuationCoContributionNonConcessional));
//
//            // reduce taxable income
//            state().income.a -= state().concessionalAdditionalSuper;
//
//            // employee contributions
//            state().totalSuperannuation.a += Number(state().additionalSuper);
//
//
//
//            // adjust non concessional
//            if (state().totalSuperannuation.a <= concessionalCap) {
//                state().superannuationConcessional = state().totalSuperannuation.a;
//            } else if (state().totalSuperannuation.a <= (nonConcessionalCap + concessionalCap)) {
//                state().superannuationConcessional = concessionalCap
//                state().superannationNonConcessional = state().totalSuperannuation.a - concessionalCap;
//            } else {
//                // excess super
//                state().superannuationConcessional = concessionalCap
//                state().superannationNonConcessional = nonConcessionalCap;
//                state().superannuationExcess = state().totalSuperannuation.a - concessionalCap - nonConcessionalCap;
//                state().warnings.superannuation.push("You have an excess of non-concessional superannuation of $" + formatMoney(state().superannuationExcess, 0));
//            }
//        }
//
//
//        // remaining limits
//        state().superannationConcessionalRemaining = concessionalCap - state().superannuationConcessional;
//        state().superannationNonConcessionalRemaining = nonConcessionalCap - state().superannationNonConcessional;
//
//        // tax paid by super fund
//        const taxableSuper = Math.min(concessionalCap, state().totalSuperannuation.a);
//        state().superannuationConcessionalTax = taxableSuper * concessionalTax
//
//        // Excess superannuation taxed at fixed rate (47%);
//        state().superannuationExcessTax = state().superannuationExcess * nonConcessionalExcessTax;
//
//        state().superannuationTax.a = state().superannuationConcessionalTax;
//        state().superannuationTax.a = Math.max(0, state().superannuationTax.a);
//
//        state().superannuationTax.m = state().totalSuperannuation.m * concessionalTax;
//        state().superannuationTax.f = state().totalSuperannuation.f * concessionalTax;
//        state().superannuationTax.w = state().totalSuperannuation.w * concessionalTax;
//
//
//
//        // Government co-contribution - added after tax
//        state().totalSuperannuation.a += state().superannuationCoContribution
//
//
//        // non concessional super that is taxable
//        // start by assuming that all non-con is taxable
//        let taxedNonConcessional = state().superannationNonConcessional;
//        // if there is voluntary super, take this from the non-con
//        if (state().adjustSuperannuation) taxedNonConcessional = Math.max(0, state().superannationNonConcessional - state().concessionalAdditionalSuper);
//        // use this figure
//        state().superannationTaxableNonConcessional = taxedNonConcessional;
//        // increase taxable income
//        state().income.a += taxedNonConcessional;
//
//
//        // co contribution
//        state().superannationNonConcessional += state().superannuationCoContributionNonConcessional;
//
//        if (Calculator.isDebug) console.log("calculateTotalSuperannuation -> superannationConcessionalRemaining:", state().superannationConcessionalRemaining, concessionalCap, state().superannuationConcessional, "superannationNonConcessional: ", state().superannationNonConcessional)
//
//        return Calculator;
//    },
//
//
//
//
//
//
//    calculateSuperannuationLISTO: () => {
//
//        if (TaxData().superannuationLISTO === undefined) {
//            state().listo = 0;
//            console.log("No 'listo' data")
//            return Calculator;
//        }
//
//        const limit = TaxData().superannuationLISTO.maxIncome;
//
//
//        // this is done later in " CalculatrTaxable income", but it is duplicated here for this calculation
//        let adjustedTaxableIncome = state().income.a;
//
//
//
//        // reportable super contributions are the contributions made by you or your employee on top of the super guarentee
//        if (state().adjustSalaryScaracfice) {
//            adjustedTaxableIncome += Number(state().superannuationSacrafice.a);
//        }
//        if (state().adjustDeductions === true) {
//            adjustedTaxableIncome -= Number(state().taxableDeductions);
//        }
//        if (state().adjustFringeBenefits === true) {
//            adjustedTaxableIncome += Number(state().fringeBenefits);
//        }
//
//
//        // depaendants
//        if(state().dependants === true && state().dependantsCount > 0){
//            adjustedTaxableIncome -= Number(state().childSupport);
//        }
//
//        // Eligibility
//        if (adjustedTaxableIncome <= limit) {
//            const rate = TaxData().superannuationLISTO.contributionRate;
//            const maxEntitlement = TaxData().superannuationLISTO.maxEntitlement;
//            const minContribution = TaxData().superannuationLISTO.minContribution;
//
//            let LISTO = state().superannuation.a * rate;
//            LISTO = Math.min(maxEntitlement, LISTO);
//            LISTO = Math.max(minContribution, LISTO);
//
//            // LISTO = Math.min( state().superannuationTax.a, LISTO);
//            // offset can't be greater than the tax applied
//            if ((state().superannuationTax.a - LISTO) < 0) { LISTO = state().superannuationTax.a } // offset cannot be less than incomeTax
//
//            state().listo = LISTO;
//
//        } else {
//            // reset
//            state().listo = 0;
//        }
//
//        return Calculator;
//    },
//
//
//    calculateTotalSuperannuationTax: () => {
//
//        // Deduct LISTO from super tax
//        state().superannuationTax.a = state().superannuationTax.a - state().listo;
//        state().superannuationTax.a = Math.max(0, state().superannuationTax.a);
//
//        return Calculator;
//    },
//
//    calculateSpouseSuperannautionOffset: () => {
//        if (state().adjustSpouseSuper) {
//            state().spouseSuperTaxOffset = getSpouseSuperTaxOffset(state().spouseIncome, state().spouseSuperAmount);
//        }
//        return Calculator;
//    },
//
//    calculateTaxableIncome: () => {
//
//        // taxable income
//        // subtract deductions from income and save as taxableIncome
//
//        if (state().superannationTaxableNonConcessional.a > 0) {
//            state().income.a += Number(state().superannationTaxableNonConcessional.a);
//        }
//
//
//
//        // ---------------- Adjusted taxable income ------------
//        //https://www.ato.gov.au/Individuals/Tax-return/2019/Tax-return/Adjusted-taxable-income-(ATI)-for-you-and-your-dependants-2019/
//
//        state().adjustedTaxableIncome = state().baseSalary.a;
//
//        if (state().adjustDeductions === true) {
//            state().deductions.a = Number(state().taxableDeductions);
//        } else {
//            state().deductions.a = 0;
//        }
//
//        if (state().adjustOtherIncome === true) {
//            // add to annual income
//            state().income.a += state().otherIncome;
//        }
//
//
//        if (state().capitalGains > 0) {
//            state().income.a += Number(state().capitalGains);
//        }
//
//        // subtract deductions from income
//        state().income.a -= Number(state().deductions.a);
//        state().income.m -= Number(state().deductions.m);
//        state().income.f -= Number(state().deductions.f);
//        state().income.w -= Number(state().deductions.w);
//
//
//        // Can't have negative income
//        state().income.a = Math.max(0, state().income.a);
//        state().income.m = Math.max(0, state().income.m);
//        state().income.f = Math.max(0, state().income.f);
//        state().income.w = Math.max(0, state().income.w);
//
//        state().adjustedTaxableIncome = Math.max(0, state().adjustedTaxableIncome);
//
//        // ---------------- Adjusted taxable income ------------
//        //https://www.ato.gov.au/Individuals/Tax-return/2019/Tax-return/Adjusted-taxable-income-(ATI)-for-you-and-your-dependants-2019/
//
//        // reportable super contributions are the contributions made by you or your employee on top of the super guarentee
//
//        if (state().adjustSalaryScaracfice) {
//            // this has already included
//            //state().adjustedTaxableIncome += Number(state().superannuationSacrafice.a);
//        }
//
//        // reportable contributions
//        state().adjustedTaxableIncome += Number(state().superannuationReportable.a);
//
//        // allowances
//        if (state().adjustAllowanceIncome === true) {
//            state().adjustedTaxableIncome += state().allowance.a;
//        }
//
//        if (state().adjustDeductions === true) {
//            state().adjustedTaxableIncome -= Number(state().taxableDeductions);
//        }
//
//
//        if (state().adjustFringeBenefits === true) {
//            state().adjustedTaxableIncome += Number(state().fringeBenefits);
//        }
//
//        if(state().dependants === true && state().dependantsCount > 0){
//            state().adjustedTaxableIncome -= Number(state().childSupport);
//        }
//
//
//        // Annual adjusted income also included other income
//        state().adjustedAnnualTaxableIncome = state().adjustedTaxableIncome;
//        if(state().adjustOtherIncome)  state().adjustedAnnualTaxableIncome += state().otherIncome;
//
//        // ---------------- Rebate income ------------
//        state().rebateIncome = state().adjustedAnnualTaxableIncome;
//        if (state().adjustFringeBenefits === true) {
//            // Rebate income (SAPTO) is 53% of fringe benefits;
//            state().rebateIncome = state().rebateIncome - Number(state().fringeBenefits) + Number(state().fringeBenefits) * 0.53;
//        }
//
//        if (Calculator.isDebug) console.log("Calculate Taxable income -> income: ", state().income, "  adjustedTaxableIncome:", state().adjustedTaxableIncome);
//
//        return Calculator;
//    },
//
//
//    ///////////////////////////////////////////
//    // Divisioin 293
//    ///////////////////////////////////////////
//    // Calcualtion of division293 based on annual gross income
//    // If your income and concessional contributions (CCs) are more than $250,000 in 2020/21, you may have to pay an additional 15% tax on some or all of your CCs
//    calculateDivision293: () => {
//
//        // Division 293 was introduced in 2012
//        if (!TaxData().division293) {
//            state().division293 = 0;
//            return Calculator;
//        }
//
//        // if you income plus your super is over the 293 threshold
//        // Calculate 293 on 15% of the taxable income or concessional superannuation (will invariably be the latter)
//        const division293Income = state().adjustedAnnualTaxableIncome// + state().superannuationConcessional;
//        const threshold = TaxData().division293.threshold;
//        const rate = TaxData().division293.rate;
//
//        let division293Tax = 0;
//
//        if (division293Income > threshold) {
//            // You're liable to pay Division 293 tax if you exceed the income threshold and you have taxable contributions for an income year.
//            // If your Division 293 income plus your Division 293 super contributions are greater than the Division 293 threshold, the taxable contributions will be the lesser of the Division 293 super contributions and the amount above the threshold.
//
//            let divisionLiability = division293Income - threshold;
//            divisionLiability = Math.min(state().superannuationConcessional, divisionLiability);
//
//            division293Tax = (divisionLiability * (rate / 100));
//        }
//
//        state().division293 = division293Tax;
//        // this should be added to annual tax - do this in the income tax calculation
//        return Calculator;
//    },
//
//
//    ///////////////////////////////////////////
//    // Income tax
//    ///////////////////////////////////////////
//    calculateIncomeTax: () => {
//
//        // determine the correct tax function
//        let taxFunction = {};
//        let taxFunctionPAYG = {};
//        if (state().backpacker) {
//            if (state().haveTFN) {
//                taxFunction = getBackpackerTax;
//                taxFunctionPAYG = getPAYGBackpackerTax;
//            } else {
//                taxFunction = getNonResidentTax;
//                taxFunctionPAYG = getPAYGNonResidentTax;
//            }
//        } else if (state().nonResident) {
//            taxFunction = getNonResidentTax;
//            taxFunctionPAYG = getPAYGNonResidentTax;
//        } else if (state().noTaxFree) {
//            taxFunction = getNoTaxFreeThresholdTax;
//            taxFunctionPAYG = getPAYGNoTaxFreeThresholdTax;
//        } else {
//            taxFunction = getIncomeTax;
//
//            if (state().medicareExemption) {
//                if (Number(state().medicareExemptionValue) === 1) {
//                    taxFunctionPAYG = getPAYGIncomeTaxFullMedicare;
//
//                } else {
//                    taxFunctionPAYG = getPAYGIncomeTaxHalfMedicare;
//                }
//            } else {
//                taxFunctionPAYG = getPAYGIncomeTax;
//            }
//        }
//
//
//        //-----------------------------------------------------------------------
//        // Pre budget calculation for 2021
//        //-----------------------------------------------------------------------
//
//        if (state().year === "2021") {
//            // calculate the previous PAYG rates
//            useLegacyTaxData = true;
//            state().incomeTaxWithheldMonthlyLegacy = taxFunctionPAYG(state().income.m, MONTHLY);
//            useLegacyTaxData = false;
//        }
//
//        // calculate tax
//        state().incomeTax.a = Math.round(taxFunction());
//        state().incomeTax.m = taxFunctionPAYG(state().income.m, MONTHLY)
//        state().incomeTax.f = taxFunctionPAYG(state().income.f, FORTNIGHTLY)
//        state().incomeTax.w = taxFunctionPAYG(state().income.w, WEELKY);
//
//        return Calculator;
//    },
//
//
//    ///////////////////////////////////////////
//    // Income tax - Extrsa witholding
//    ///////////////////////////////////////////
//    // Only for weeks or fortnight with 53 or 26 payments
//    calculateIncomeTaxExtraWitholding: () => {
//
//        // if (TaxData().extraWitholding) {
//
//        if (state().payments.w === 53) {
//            let bracket = TaxData().extraWitholding.weekly.brackets;
//            state().extraWithholdingTax.w = calculateBracket(state().income.w, bracket, false);
//        }
//
//        if (state().payments.f === 27) {
//            let bracket = TaxData().extraWitholding.fortnightly.brackets;
//            state().extraWithholdingTax.f = calculateBracket(state().income.f, bracket, false);
//
//        }
//
//        // } else {
//        //     console.log("No 'extraWitholding' data");
//        // }
//
//        return Calculator;
//    },
//
//
//
//    ///////////////////////////////////////////
//    // Student loans
//    ///////////////////////////////////////////
//    //  From 1 July 2019 VET Student Loan (VSL) and Student Financial Supplement Scheme (SFSS) debts will be repaid after Higher Education Loan Program (HELP) debts are discharged
//
//    calculateStudentLoans: () => {
//
//        if (!state().HELP ) return Calculator;
//
//        // HELP (HECS)
//        let taxFunction = {};
//        if (state().HELP ) {
//            if (state().nonResident || state().noTaxFree) {
//                taxFunction = getHELP_noTaxFree
//            } else {
//                taxFunction = getHELP;
//            }
//
//            //
//            state().help.a = roundToNearestCent(taxFunction(state().adjustedTaxableIncome));
//            spreadAnnualAmounts(state().help);
//            // annual calculation includes additional income
//            state().help.a = roundToNearestCent(taxFunction(state().adjustedAnnualTaxableIncome));
//
//            // attempting to conform to weekly conversions
//            // https://www.ato.gov.au/Rates/PAYG-withholding-2019-20/Schedule-8---Statement-of-formulas-for-calculating-study-and-training-support-loans-components/
//        }
//
//
//        // SFSS only (redundant)
//        // if (state().SFSS && !state().HELP) {
//        //     if (state().nonResident || state().noTaxFree) {
//        //         taxFunction = getSFSS_noTaxFree
//        //     } else {
//        //         taxFunction = getSFSS;
//        //     }
//
//        //     state().sfss.a = roundToNearestCent(taxFunction(state().adjustedTaxableIncome));
//        //     spreadAnnualAmounts(state().sfss);
//        //     state().sfss.a = roundToNearestCent(taxFunction(state().adjustedAnnualTaxableIncome));
//
//        // }
//
//        return Calculator;
//    },
//
//
//
//    ///////////////////////////////////////////
//    // Medicare
//    ///////////////////////////////////////////
//    calculateMedicare: () => {
//
//        // Medicare
//        if (state().nonResident || state().backpacker) {
//            state().medicareSurcharge = 0;
//            return Calculator;
//        }
//
//        const family = state().spouse || state().dependants;
//        const senior = state().SAPTO;
//        const dependantsCount = state().dependants ? Number(state().dependantsCount) : 0;
//        state().familyIncome = Number(state().adjustedAnnualTaxableIncome) + Number(state().spouseIncome);
//
//
//        if (family) {
//            state().medicare.a = getMedicareFamily(state().adjustedAnnualTaxableIncome, Number(state().spouseIncome), dependantsCount, senior);
//            // don't go below 0
//            state().medicare.a = Math.max(0, state().medicare.a);
//
//        } else {
//            state().medicare.a = getMedicare(state().adjustedAnnualTaxableIncome, senior);
//            // don't go below 0
//            state().medicare.a = Math.max(0, state().medicare.a);
//        }
//
//        // basline PAYG medicare levy
//        // standard unadjusted medicare levy applied to PAYG (income excludes other income)
//        const medicareBaseline = getMedicare(state().adjustedTaxableIncome);
//        state().medicare.m = medicareBaseline / month2Year;
//        state().medicare.f = medicareBaseline / fortnight2Year;
//        state().medicare.w = medicareBaseline / week2Year;
//
//
//        // ---------------  Medicare Surcharge
//        if (family) {
//            state().medicareSurcharge = getMedicareSurchargeFamily(state().familyIncome);
//        } else {
//            state().medicareSurcharge = getMedicareSurchargeSingle(state().adjustedAnnualTaxableIncome);
//        }
//
//
//        if (state().hasPrivateHealthcare) {
//            state().medicareSurchargeLiability = 0;
//        } else {
//            state().medicareSurchargeLiability = state().medicareSurcharge;
//        }
//
//        let medicareDescription = "";
//        if (senior) {
//            medicareDescription = "Senior, "
//        }
//
//        if (family) {
//            medicareDescription += "Family, "
//        } else {
//            medicareDescription += "Single, "
//        }
//
//        if (dependantsCount === 0) {
//            medicareDescription += "no dependants. "
//        } else if (dependantsCount === 1) {
//            medicareDescription += "1 dependant. "
//        } else {
//            medicareDescription += dependantsCount + " dependants. ";
//        }
//
//        // if (!state().hasPrivateHealthcare && state().medicareSurcharge > 0) {
//        //     medicareDescription += `Includes surcharge of $${formatMoney(state().medicareSurcharge, 0)}`;
//        // }
//
//        state().medicareDescription = medicareDescription;
//
//        return Calculator;
//
//    },
//
//    calculateMedicareAdjustment: () => {
//
//        // TODO: Che calculations to include/exclude deductions, FB, other income... baseSalary.a?
//
//        // Medicare shade-in for scale 2 (Claim tax free threshold) and scale 6 (Half Medicare) only
//
//
//        if (state.backpacker || state.nonResident || state.noTaxFree || state.medicareExemptionValue === 1) {
//            return Calculator;
//        }
//
//        let scale = state.medicareExemptionValue === 0.5 ? SCALE6 : SCALE2;
//        const dependantsCount = state().dependants ? Number(state().dependantsCount) : 0;
//        const family = dependantsCount > 0;
//
//        let WLA = getMedicareAdjustment(state().income.a, dependantsCount, state().spouse, state().spouseIncome / 52, scale);
//
//
//        if (state().medicareExemption) {
//
//            state().medicare.w -= state().medicare.w * state().medicareExemptionValue;
//            state().medicare.f -= state().medicare.f * state().medicareExemptionValue;
//            state().medicare.m -= state().medicare.m * state().medicareExemptionValue;
//            state().medicare.a -= state().medicare.a * state().medicareExemptionValue;
//        }
//
//        if (WLA > 0 && family) {
//            state().medicareFamilyAdjustment = true;
//
//        }else{
//            // disable this option
//            state().applyMedicareAdjustment = false;
//        }
//
//        state().medicareAdjustment.w = WLA;
//
//        state().medicareAdjustment.f = WLA * 2;
//        state().medicareAdjustment.m = (WLA * 13) / 3;
//
//        // the adjustment is only used to reduce PAYG
//        state().medicareAdjustment.a = 0;
//
//        // remove silly -0 and +0
//        cleanZeros(state().medicareAdjustment);
//
//        return Calculator;
//
//    },
//
//
//
//    ///////////////////////////////////////////
//    // Offsets
//    ///////////////////////////////////////////
//    calculateOffsets: () => {
//
//        if (state().nonResident || state().noTaxFree || state().backpacker) return Calculator;
//
//        //    The eligibility for the low income tax offset is based on taxable income (not ATI)
//
//        state().lito = getLITO(state().income.a);
//        state().lamito = getLAMITO(state().income.a);
//
//        if (state().SAPTO) {
//            // spouseIncome is weekly income
//            state().sapto = getSAPTO(state().rebateIncome, state().spouse, state().spouseSeparated, state().spouseIncome);
//        }
//
//        state().offsets.a = state().lito + state().mawto + state().mito + state().lamito + state().sapto + state().spouseSuperTaxOffset;
//
//        // prevent any annual tax offests from exceeding income tax
//        // This is income tax and not gross tax
//        // console.log("tax overflow: ", state().incomeTax.a + state().offsets.a)
//        if ((state().incomeTax.a - state().offsets.a) < 0) {
//            state().offsets.a = state().incomeTax.a;
//        }
//
//
//        return Calculator;
//    },
//
//    ///////////////////////////////////////////
//    // Gross Tax
//    ///////////////////////////////////////////
//
//    calculateGrossTax: () => {
//
//        state().otherTaxesAndLevies = getOther(state().income.a); // this should be a negative amount
//
//        state().otherTax.a = state().help.a + state().sfss.a + state().levies.a + state().otherTaxesAndLevies + state().superannuationExcessTax + state().division293;
//        state().otherTax.m = state().help.m + state().sfss.m + state().levies.m;
//        state().otherTax.f = state().help.f + state().sfss.f + state().levies.f;
//        state().otherTax.w = state().help.w + state().sfss.w + state().levies.w;
//
//
//        // NORMALISE TAX TABLE DATA
//        // if the payg figure was using the ATO calculations - deduct medicare and other taxes
//        if (state().PAYG) {
//            // this needs to be taken from the taxPAYG value as the ATO tax tables include it
//            // also includes levies
//
//            if (state().incomeTax.w > 0) state().incomeTax.w -= (state().medicare.w + state().levies.w);
//            if (state().incomeTax.f > 0) state().incomeTax.f -= (state().medicare.f + state().levies.f);
//            if (state().incomeTax.m > 0) state().incomeTax.m -= (state().medicare.m + state().levies.m);
//
//        }
//
//        state().grossTax.a = state().incomeTax.a + state().extraWithholdingTax.a + state().medicare.a + state().medicareSurchargeLiability + state().otherTax.a - state().offsets.a;
//        state().grossTax.m = state().incomeTax.m + state().extraWithholdingTax.m + state().medicare.m + state().otherTax.m - state().offsets.m;
//        state().grossTax.f = state().incomeTax.f + state().extraWithholdingTax.f + state().medicare.f + state().otherTax.f - state().offsets.f;
//        state().grossTax.w = state().incomeTax.w + state().extraWithholdingTax.w + state().medicare.w + state().otherTax.w - state().offsets.w;
//
//
//
//        if(state().applyMedicareAdjustment){
//            state().grossTax.m -= state().medicareAdjustment.m;
//            state().grossTax.f -= state().medicareAdjustment.f;
//            state().grossTax.w -= state().medicareAdjustment.w;
//
//        }
//
//
//
//        // rounding?
//        const rounding = true;
//        if (rounding) {
//            state().grossTax.a = Math.round(state().grossTax.a);
//            // state().grossTax.m = Math.round(state().grossTax.m);
//            // state().grossTax.f = Math.round(state().grossTax.f);
//            // state().grossTax.w = Math.round(state().grossTax.w);
//        }
//
//        if (Calculator.isDebug) console.log("Calculate Gross Tax -> grossTax: ", state().grossTax);
//
//
//        return Calculator;
//    },
//
//    ///////////////////////////////////////////
//    // Net income
//    ///////////////////////////////////////////
//    calculateNetIncome: () => {
//
//        // sum up income, tax and include deductions
//        state().net.a = state().income.a - state().grossTax.a + state().deductions.a;
//        state().net.m = state().income.m - state().grossTax.m + state().deductions.m;
//        state().net.f = state().income.f - state().grossTax.f + state().deductions.f;
//        state().net.w = state().income.w - state().grossTax.w + state().deductions.w;
//
//        // remove sacraficed non concessional super from pay - this is calcualted for tax but not included in pay - it is going into the super fund
//        state().net.a -= state().superannuationUntaxedNonConcessional;
//
//        // add voluntry concessional back onto pay
//        state().net.a += state().concessionalAdditionalSuper;
//
//
//        return Calculator;
//    },
//}
//
//
//
//
/////////////////////////////////////////////
//// Income Aux
/////////////////////////////////////////////
//
//const getInputIncome = () => {
//    // append any adjustment value to the input income
//    return Number(state().salary) + Number(state().adjustment);
//}
//
//
//
/////////////////////////////////////////////
//// Superannuation Aux
/////////////////////////////////////////////
//
//// getSuperannuation(state().baseSalary.a, true, options);
//const getSuperannuation = (taxableIncome, subtractive, rate) => {
//    let superannuation = 0;
//
//    if (TaxData().superannuation) {
//        // Use the bracket calculator
//        let superBracket = TaxData().superannuation.brackets;
//
//        const inc = TaxData().superannuation.incremental;
//        let cap = TaxData().superannuation.cap ? TaxData().superannuation.cap : 0;
//        cap = 0; // <--------------------------------------------------------------------------------------- Fix this
//        //let income = Math.min(cap, taxableIncome);
//        //let superannuation = calculateBracket(taxableIncome, customBracket, inc, subtractive, 0);
//
//        superBracket = [{ from: 0, to: 0, type: "percent", nearest: 1, value: rate }];
//        superannuation = calculateBracket(taxableIncome, superBracket, inc, subtractive, cap);
//
//    } else {
//        console.log("No 'superannuation' data");
//    }
//
//    return superannuation;
//}
//
//
//
/////////////////////////////////////////////
//// Income Tax Aux
/////////////////////////////////////////////
//
//const getIncomeTax = (overrideIncome) => {
//    let tax = 0;
//
//    if (TaxData().tax) {
//        const bracket = TaxData().tax.brackets;
//        const inc = TaxData().tax.incremental;
//        const taxableIncome = overrideIncome ? overrideIncome : state().income.a;
//        //export const calculateBracket = (v, b, incremental, subtractive, cap, debug) => {
//        tax = calculateBracket(taxableIncome, bracket, inc);
//    } else {
//        console.log("No 'tax' data")
//    }
//    return tax;
//}
//
//const getPAYGIncomeTax = (income, cycle) => {
//
//    if (TaxData().tax.payg === undefined) {
//        state().PAYG = false;
//        return divideTaxByCycle(getIncomeTax(), cycle);
//    }
//    state().PAYG = true;
//    let tax = calculatePAYG(income, TaxData().tax.payg, cycle);
//
//
//    return tax
//}
//
//
//const getPAYGIncomeTaxHalfMedicare = (income, cycle) => {
//    if (TaxData().taxMedicareHalf === undefined || TaxData().taxMedicareHalf.payg === undefined) {
//        state().PAYG = false;
//        return getPAYGIncomeTax(income, cycle);
//    }
//    state().PAYG = true;
//    let tax = calculatePAYG(income, TaxData().taxMedicareHalf.payg, cycle);
//    return tax
//}
//
//
//const getPAYGIncomeTaxFullMedicare = (income, cycle) => {
//    if (TaxData().taxMedicareFull === undefined || TaxData().taxMedicareFull.payg === undefined) {
//        state().PAYG = false;
//        return getPAYGIncomeTax(income, cycle);
//    }
//    state().PAYG = true;
//    let tax = calculatePAYG(income, TaxData().taxMedicareFull.payg, cycle);
//    return tax
//}
//
//
//
//const getNoTaxFreeThresholdTax = () => {
//    let tax = 0;
//
//    if (TaxData().taxNoFreeThreshold) {
//        const bracket = TaxData().taxNoFreeThreshold.brackets;
//        const inc = TaxData().taxNoFreeThreshold.incremental;
//        tax = calculateBracket(state().income.a, bracket, inc);
//    } else {
//        console.log("No 'taxNoFreeThreshold' data")
//    }
//    return tax;
//}
//
//const getPAYGNoTaxFreeThresholdTax = (income, cycle) => {
//    if (TaxData().taxNoFreeThreshold.payg === undefined) {
//        state().PAYG = false;
//        return divideTaxByCycle(getNoTaxFreeThresholdTax(), cycle);
//    }
//    state().PAYG = true;
//    return calculatePAYG(income, TaxData().taxNoFreeThreshold.payg, cycle);
//}
//
//const getNonResidentTax = () => {
//    let tax = 0;
//    if (TaxData().taxNonResident) {
//        const bracket = TaxData().taxNonResident.brackets;
//        const inc = TaxData().taxNonResident.incremental;
//        tax = calculateBracket(state().income.a, bracket, inc);
//    } else {
//        console.log("No 'taxNonResident' data")
//    }
//    return tax;
//}
//
//const getPAYGNonResidentTax = (income, cycle) => {
//    if (TaxData().taxNonResident.payg === undefined) {
//        state().PAYG = false;
//        return divideTaxByCycle(getNonResidentTax(), cycle);
//    }
//    state().PAYG = true;
//    return calculatePAYG(income, TaxData().taxNonResident.payg, cycle);
//}
//
//const getBackpackerTax = () => {
//    let tax = 0;
//    if (TaxData().taxBackpacker) {
//        const bracket = TaxData().taxBackpacker.brackets;
//        const inc = TaxData().taxBackpacker.incremental;
//        tax = calculateBracket(state().income.a, bracket, inc);
//    } else {
//        console.log("No 'taxBackpacker' data")
//    }
//    return tax;
//}
//
//const getPAYGBackpackerTax = (income, cycle) => {
//
//    // backpacker PAY can be paid as if this is the only payment per year.
//    // add comment: If you have paid the Working Holiday Maker more than $37,000 in this income year the above calculation is incorrect. Please refer to the Tax Table Link opens in new window for Working Holiday Makers for instructions.
//    if (TaxData().taxBackpacker.payg === undefined) {
//        state().PAYG = false;
//        // SPECIAL CASE !!
//        const bracket = TaxData().taxBackpacker.brackets;
//        const inc = TaxData().taxBackpacker.incremental;
//        return calculateBracket(income, bracket, inc);
//
//        //return divideTaxByCycle(getBackpackerTax(), cycle);
//    }
//
//    state().PAYG = true;
//    return calculatePAYG(income, TaxData().taxBackpacker.payg, cycle);
//}
//
//
//
/////////////////////////////////////////////
//// Student Loans
/////////////////////////////////////////////
//
//const getHELP = (taxableComponent, include, rounding) => {
//    let help = 0;
//    if (TaxData().help) {
//        let bracket = TaxData().help.brackets;
//        let inc = TaxData().help.incremental;
//        if (rounding) {
//            help = calculateBracketATORounding(taxableComponent, bracket, inc);
//        } else {
//            help = calculateBracket(taxableComponent, bracket, inc);
//        }
//    } else {
//        console.log("No 'help' data")
//    }
//    return help;
//}
//
//const getHELP_noTaxFree = (taxableComponent, include, rounding) => {
//    // if(!include) return 0;
//    let help = 0;
//    if (TaxData().help_noTaxFree) {
//        let bracket = TaxData().help_noTaxFree.brackets;
//        let inc = TaxData().help_noTaxFree.incremental;
//        if (rounding) {
//            help = calculateBracketATORounding(taxableComponent, bracket, inc);
//        } else {
//            help = calculateBracket(taxableComponent, bracket, inc);
//        }
//    } else {
//        help = getHELP(taxableComponent, include, rounding);
//    }
//    return help;
//}
//
//// const getSFSS = (taxableComponent, include, rounding) => {
////     let sfss = 0;
////     if (TaxData().sfss) {
////         let bracket = TaxData().sfss.brackets;
////         let inc = TaxData().sfss.incremental;
////         if (rounding) {
////             sfss = calculateBracketATORounding(taxableComponent, bracket, inc);
////         } else {
////             sfss = calculateBracket(taxableComponent, bracket, inc);
////         }
////     } else {
////         console.log("No 'sfss' data")
////     }
////     return sfss;
//// }
//
//// const getSFSS_noTaxFree = (taxableComponent, include, rounding) => {
////     // if(!include) return 0;
////     let sfss = 0;
////     if (TaxData().sfss_noTaxFree) {
////         let bracket = TaxData().sfss_noTaxFree.brackets;
////         let inc = TaxData().sfss_noTaxFree.incremental;
////         if (rounding) {
////             sfss = calculateBracketATORounding(taxableComponent, bracket, inc);
////         } else {
////             sfss = calculateBracket(taxableComponent, bracket, inc);
////         }
////     } else {
////         sfss = getSFSS(taxableComponent, include, rounding);
////     }
////     return sfss;
//// }
//
//
//
/////////////////////////////////////////////
//// Medicare Aux
/////////////////////////////////////////////
//export const getMedicare = (income, senior = false) => {
//    let medicare = 0;
//    let data = undefined;
//
//    if (senior && TaxData().medicareSenior) data = TaxData().medicareSenior;
//    if (!senior && TaxData().medicare) data = TaxData().medicare;
//
//    if (!data) {
//        console.log(`No 'medicare' data. ${senior ? "(senior)" : ""}`)
//        return 0
//    }
//
//    medicare = calculateBracket(income, data.brackets, data.incremental, false, 0);
//
//    // nearest cent
//    return roundToNearestCent(medicare);
//}
//
//
//
//// ref: https://www.ato.gov.au/Individuals/myTax/2020/In-detail/medicare-levy-reduction-or-exemption/?anchor=spouse
//
//export const getMedicareFamily = (income, spouseIncome = 0, dependantsCount = 0, senior = false) => {
//
//    let medicareData = undefined;
//    if (senior && TaxData().medicareSeniorFamily) medicareData = TaxData().medicareSeniorFamily;
//    if (!senior && TaxData().medicareFamily) medicareData = TaxData().medicareFamily;
//
//    let brackets = medicareData.brackets;
//    const dependantsOffset = medicareData.dependants ? dependantsCount * Number(medicareData.dependants) : 0;
//
//    if (dependantsOffset > 0) {
//        // modify brackets for dependants offset - first clone the brackets then offset from,to
//
//        brackets = medicareData.brackets.map(obj => {
//            const _obj = { ...obj };
//            const from = _obj.from;
//            const to = _obj.to;
//            _obj.from = from > 0 ? from + dependantsOffset : 0;
//            _obj.to = to > 0 ? to + dependantsOffset : 0;
//            return _obj
//        });
//
//        // calculate runout - blend offset 10% rate into 2% rate without a step
//        const m1 = brackets[brackets.length - 1].value / 100;
//        const m2 = brackets[brackets.length - 2].value / 100;
//        const runout = m1 * (dependantsOffset / (m2 - m1));
//
//        brackets[brackets.length - 1].from += runout;
//        brackets[brackets.length - 2].to += runout;
//    }
//
//    // const familyIncome = spouseIncome*0.704062 + income;
//    const familyIncome = spouseIncome*0.8 + income;
//    const familyIncomeThreshold = spouseIncome + income;
//    // if the family income in the top bracket?
//
//    if(familyIncomeThreshold >= brackets[brackets.length - 1].from){
//        // no family benefit
//        return getMedicare(income, senior);
//    }
//
//    const baseline = getMedicare(income, senior);
//    const reduction = calculateBracket(familyIncome, brackets, medicareData.incremental, false, 0);
//
//    // these numbers get weird when sposeincome -> income
//    // limit blow out:
//
//    return Math.min(baseline, reduction);
//    // return calculateBracket(familyIncome, brackets, medicareData.incremental, false, 0);
//}
//
//
//
//// The Medicare levy is also shaded in for scale 6. The Medicare levy parameters for scales 2 and 6 are as follows:
//
//export const getMedicareAdjustment = (taxableComponent, dependantsCount, spouse, spouseIncomeWeekly, scale) => {
//
//    // Only applied to families
//    if (!spouse && dependantsCount === 0) return 0;
//
//
//    let adjustment = 0;
//    const medicareData = TaxData().medicareAdjustment;
//
//    // Scale 2 - Regular tax payer
//    // Scale 6 - Claiming Half medicare
//
//    //let scale = "scale2" //"scale6";
//
//    //const earningThreshold = medicareData.earningThreshold[scale];
//    const shadeInThreshold = medicareData.shadeInThreshold[scale];
//    const annualThreshold = medicareData.annualThreshold[scale];
//    const additioalChild = medicareData.additioalChild[scale];
//    const shadeOutMultiplier = medicareData.shadeOutMultiplier[scale];
//    const shadeOutDivisor = medicareData.shadeOutDivisor[scale];
//    const weeklyAdjustment = medicareData.weeklyAdjustment[scale];
//    const medicareLevy = medicareData.medicareLevy[scale];
//
//    if (dependantsCount >= 1) {
//        adjustment = dependantsCount * additioalChild;
//    }
//
//    //let startThreshold = Number(medicareData.brackets[1].from);
//    let spouseIncome = spouseIncomeWeekly * 52;
//    //let assesableIncome = taxableComponent + (spouseIncome) * 0.8 - adjustment;
//    let familyIncome = spouseIncome + taxableComponent;
//
//
//    let weekly = Math.floor(familyIncome / 52) + 0.99;
//
//    let WFT = (adjustment + annualThreshold) / 52;
//    WFT = Math.round(WFT * 100) / 100;
//
//    let SOP = Math.floor((WFT * shadeOutMultiplier) / shadeOutDivisor);
//
//    let WLA = 0
//    //if( weekly > earningThreshold  && weekly < SOP){
//    if (weekly < shadeInThreshold) {
//        WLA = (weekly - weeklyAdjustment) * shadeOutMultiplier;
//    }
//    else if (weekly >= shadeInThreshold && weekly < WFT) {
//        WLA = weekly * medicareLevy;
//    }
//    else if (weekly >= WFT && weekly < SOP) {
//        WLA = (WFT * medicareLevy) - ((weekly - WFT) * shadeOutDivisor);
//    }
//    // }
//    // WLA = (WFT * medicareLevy) - (( weekly - WFT) * shadeOutDivisor);
//    WLA = Math.round(WLA);
//
//    return WLA;
//}
//
//
//
//
//const getMedicareSurchargeSingle = (taxableComponent) => {
//    let medicare_surcharge = 0;
//    if (TaxData().medicareSurcharge) {
//        let bracket = TaxData().medicareSurcharge.brackets;
//        let inc = TaxData().medicareSurcharge.incremental;
//        medicare_surcharge = calculateBracket(taxableComponent, bracket, inc, false);
//    } else {
//        console.log("No 'medicareSurcharge' data")
//    }
//    return medicare_surcharge;
//}
//
//const getMedicareSurchargeFamily = (familyInocme) => {
//    let medicare_surcharge = 0;
//    if (TaxData().medicareSurchargeFamily) {
//        let bracket = TaxData().medicareSurchargeFamily.brackets;
//        let inc = TaxData().medicareSurchargeFamily.incremental;
//        medicare_surcharge = calculateBracket(familyInocme, bracket, inc, false);
//    } else {
//        console.log("No 'medicareSurchargeFamily' data")
//    }
//    return medicare_surcharge;
//}
//
//
//
//
/////////////////////////////////////////////
//// Offsets (Aux)
/////////////////////////////////////////////
//const getLITO = (taxableComponent) => {
//    let offset = 0;
//
//    if (TaxData().lito) {
//        let bracket = TaxData().lito.brackets;
//        let inc = TaxData().lito.incremental;
//        offset = calculateBracket(taxableComponent, bracket, inc, false);
//
//        if (offset < 0) offset = 0;
//        if ((taxableComponent - offset) < 0) { offset = 1 * taxableComponent } // offset cannot be less than incomeTax
//        //offset  = offset > 0 ? -1*offset : 0;
//    } else {
//        console.log("No 'lito' data")
//    }
//    return offset;
//}
//
//const getLAMITO = (taxableComponent) => {
//    // does it apply?
//    let offset = 0;
//    if (TaxData().lamito) {
//        let bracket = TaxData().lamito.brackets;
//        let inc = TaxData().lamito.incremental;
//        //function calculateBracket(v, b, incremental, subtractive, cap, debug){
//        offset = calculateBracket(taxableComponent, bracket, inc, false);
//
//        if (offset < 0) offset = 0;
//        if ((taxableComponent - offset) < 0) { offset = 1 * taxableComponent } // offset cannot be less than incomeTax
//        //offset  = offset > 0 ? -1*offset : 0;
//    } else {
//        console.log("No 'lamito' data")
//    }
//    return offset;
//}
//
//// const getMITO = (incomeTax) => {
////     let offset = 0;
////     if (TaxData().mito) {
////         let bracket = TaxData().mito.brackets;
////         let inc = TaxData().mito.incremental;
////         offset = -1 * calculateBracket(incomeTax, bracket, inc, false);
////         if (offset > 0) offset = 0;
////         if ((incomeTax + offset) < 0) { offset = -1 * incomeTax } // offset cannot be less than incomeTax
////         return offset;
////     } else {
////         console.log("No 'mito' data")
////     }
////     return 0;
//// }
//
//
//
//const getSAPTO = (rebateIncome, married, separated, spouseIncome) => {
//    let offset = 0;
//
//    if (TaxData().sapto) {
//
//        let bracket = TaxData().sapto.brackets ? TaxData().sapto.brackets : 0;
//        let inc = TaxData().sapto.incremental;
//        let income = rebateIncome;
//
//        if (!married && TaxData().sapto.single) {
//            bracket = TaxData().sapto.single.brackets;
//
//        }
//        if (married && !separated && TaxData().sapto.married) {
//            bracket = TaxData().sapto.married.brackets;
//        }
//
//        if (married && separated && TaxData().sapto.illness) {
//            bracket = TaxData().sapto.illness.brackets;
//        }
//
//        offset = 1 * calculateBracket(income, bracket, inc, false, false);
//        if (offset < 0) offset = 0;
//        if ((income - offset) < 0) { offset = 1 * income } // offset cannot be less than incomeTax
//        return offset;
//    } else {
//        console.log("NO 'sapto'' data!!")
//    }
//
//    return 0;
//}
//
//
//
//
//// const getMAWTO = (incomeTax) => {
////     let offset = 0;
////     if (TaxData().mawto) {
////         let bracket = TaxData().mawto.brackets;
////         let inc = TaxData().mawto.incremental;
//
////         offset = calculateBracket(incomeTax, bracket, inc, false, 0);
////         if (offset > 0) offset = 0;
////         if ((incomeTax + offset) < 0) { offset = -1 * incomeTax } // offset cannot be less than incomeTax
////     } else {
////         console.log("No 'mawto' data")
////     }
////     return offset;
//// }
//
//const getOther = (incomeTax) => {
//    let offset = 0;
//    if (TaxData().other) {
//        for (let i = 0; i < TaxData().other.length; i++) {
//            let bracket = TaxData().other[i].brackets;
//            let inc = TaxData().other[i].incremental;
//            offset += calculateBracket(incomeTax, bracket, inc, false);
//        }
//    } else {
//        console.log("No 'other' data")
//    }
//    return offset;
//}
//
//
//const getSpouseSuperTaxOffset = (spouseIncome, spouseContributions) => {
//    let taxOffset = 0;
//
//    if (TaxData().superannuationSpouseTaxOffset) {
//        const bracket = TaxData().superannuationSpouseTaxOffset.brackets;
//        const inc = TaxData().superannuationSpouseTaxOffset.incremental;
//        const rate = Number(TaxData().superannuationSpouseTaxOffset.rate);
//        const spouseOffset = calculateBracket(spouseIncome, bracket, inc);
//        taxOffset = Math.min(spouseContributions * rate, spouseOffset * rate);
//
//    } else {
//        console.log("No 'superannuationSpouseTaxOffset' data")
//    }
//    return taxOffset;
//}
//
//
//
//
//
/////////////////////////////////////////////
//// Auxillery
/////////////////////////////////////////////
//
//const zero = (obj) => {
//    obj.a = obj.m = obj.f = obj.w = 0
//}
//
//// get rid of negaive zeros
//// -0 and +0 are stupid. Let 0 be 0
//const cleanZeros = (obj) => {
//    Object.keys(obj).map(k => {
//        if (obj[k] === -0) obj[k] = 0;
//        return true;
//    })
//}
//
//const divideTaxByCycle = (tax, cycle) => {
//    switch (cycle) {
//        case WEELKY:
//            return tax / week2Year;
//        case FORTNIGHTLY:
//            return tax / fortnight2Year;
//        case MONTHLY:
//            return tax / month2Year;
//        default:
//            break;
//    }
//    return tax;
//}
//
//
//// Take an annual value object and spread the annual figure to w,f and m
//export const spreadAnnualAmounts = (obj) => {
//    obj.m = obj.a / month2Year;
//    obj.f = obj.a / fortnight2Year;
//    obj.w = obj.a / week2Year;
//    return obj;
//}
//
//
//// Take a single annual value and return an annual value object
//export const spreadAnnualValue = (val) => {
//    return spreadAnnualAmounts({ a: val })
//}
//
//
/////////////////////////////////////////////
//// PAYG
/////////////////////////////////////////////
//const calculatePAYG = (income, paygBrackets, cycle) => {
//
//    // reduce income to weekly
//    let paygIncome;
//    switch (cycle) {
//        case MONTHLY:
//            // "if the result is an amount ending in 33 cents, add one cent"
//            let cents = Math.round(100 * (income - Math.floor(income)));
//            if (cents === 33) income += 0.01;
//            paygIncome = Math.floor((income * 3) / 13);
//            paygIncome += 0.99;
//            break;
//        case FORTNIGHTLY:
//            paygIncome = income / 2;
//            paygIncome = Math.floor(paygIncome);
//            paygIncome += 0.99;
//            break;
//        case WEELKY:
//        default:
//            paygIncome = Math.floor(income);
//            paygIncome += 0.99;
//            break;
//
//    }
//
//    let a = 0;
//    let b = 0;
//    // find bracket
//    for (let i = 0; i < paygBrackets.length; i++) {
//        if (paygIncome < paygBrackets[i].income || paygBrackets[i].income === 0) {
//            a = paygBrackets[i].a;
//            b = paygBrackets[i].b;
//            break;
//        }
//    }
//
//    let tax = paygIncome * a - b;
//    tax = Math.round(tax);
//
//    //convert back to cycle
//    switch (cycle) {
//        case MONTHLY:
//            tax = (tax * 13) / 3
//            break;
//        case FORTNIGHTLY:
//            tax = tax * 2;
//            break;
//        default:
//            break;
//
//    }
//    return tax;
//}
//
//
//
/////////////////////////////////////////////
//// Bracket calculations
/////////////////////////////////////////////
//
//export const getBracket = (v, b) => {
//    if (!v || !b) return false;
//    // round to the nearest week
//    for (let i = 0; i < b.length; i++) {
//        if (v >= b[i].from) {
//            if (v < b[i].to || b[i].to === 0) {
//                return b[i];
//            }
//        }
//    }
//    return b[0];
//}
//
//
//export const calculateBracket = (v, b, incremental, subtractive, cap, debug) => {
//    // round to the nearest cent
//    return calculateBracketWithRounding(v, b, incremental, subtractive, cap, debug, 0.01);
//}
//
//const calculateBracketATORounding = (v, b, incremental, subtractive, cap, debug) => {
//    // round to the nearest week
//    return calculateBracketWithRounding(v, b, incremental, subtractive, cap, debug, 0.52);
//}
//
//const calculateBracketWithRounding = (v, b, incremental, subtractive, cap, debug, rounding) => {
//    let r = 0;
//    let inc = (incremental === 1) ? true : false;
//
//    rounding = rounding || 0.01;
//    // v for value
//    // b for brackets
//    for (let i = 0; i < b.length; i++) {
//        // for each of the brackets
//        let from = Number(b[i].from) || 0;
//        let to = Number(b[i].to) || 0;
//        let nearest = Number(b[i].nearest) || 1;
//        let val = Number(b[i].value) || 0;
//        let start = Number(b[i].start) || 0;
//        let end = Number(b[i].end) || 0;
//        let bracketAmount;
//        let type = b[i].type;
//
//        if (debug) console.log(" ");
//        if (debug) console.log("bracket: from:" + from + " to: " + to + " amount: " + val + " bracket value: " + v);
//
//        if (b[i].incremental !== undefined) {
//            // this bracket has an incremental override (medicare)
//            if (debug) console.log("incremental bracket! ");
//            inc = (b[i].incremental === 1 || b[i].incremental === "true") ? true : false;
//        }
//
//        // trigger on active bracket
//        if (v >= from) {
//
//            // part bracket > from and < to, otherwise it is complete bracket
//            let partBracket = (v <= to || to === 0);
//
//            // calculate the value within this bracket (check cap)
//            if (partBracket) {
//                bracketAmount = (Math.ceil((v - from) / nearest)) * nearest;
//            } else {
//                bracketAmount = (Math.ceil((to - from) / nearest)) * nearest;
//            }
//
//
//            if (debug) console.log("Current bracket... type: " + b[i].type + " i:" + i + " from:" + from + " to:" + to + " val: " + v, "  part: ", partBracket, "  inc: ", inc, " -> r:", r);
//
//
//            // if not incremental only concern is the final brackets
//            if (!inc && !partBracket) continue;
//
//            switch (type) {
//                case "fixed":
//                    r = inc ? r + val : val; // add value of fixed component
//                    if (debug) console.log("fixed bracket: ", r);
//                    break;
//
//                case "rate":
//                    let rateValue = start + (bracketAmount * val / 100);
//                    if (rateValue > end && val > 0) rateValue = end; // upper limit on improving rate
//                    if (rateValue < end && val < 0) rateValue = end; // lower limit on decending rate
//                    r = inc ? r + rateValue : rateValue;
//                    if (debug) console.log("rate bracket: ", r);
//                    break;
//
//                case "percent":
//                    if (partBracket) {
//                        if (debug) console.log("part bracket: ", partBracket);
//
//                        // part bracket
//                        // if the brackets are incremental take the percentage from the individual bracket
//                        // otherwise take a percentage from the total value
//                        if (inc) {
//                            if (debug) console.log("include bracket... ");
//                            // apply cap - (superannuation)
//                            if (bracketAmount > cap && cap > 0) bracketAmount = cap;
//                            if (debug) console.log("include bracket... " + bracketAmount + " val: " + val);
//                            // ATO rounding
//                            // let percentValue = rounding * Math.round((bracketAmount * (val / 100)) / rounding);
//                            let percentValue = ((bracketAmount * (val / 100)));
//                            // subtractive? cap?
//                            r += percentValue;
//                            if (debug) console.log("include bracket... = ", percentValue, r);
//
//                        } else {
//                            // take the full amount not just the partial bracket value
//                            let percentValue = rounding * Math.round((v * (val / 100)) / rounding);
//                            // this is a superannuation option
//                            if (subtractive) { percentValue /= (1 + (val / 100)) }
//
//                            // check cap (superannuation)
//                            if (percentValue > cap && cap > 0) { percentValue = cap }
//
//                            r = percentValue;
//                            if (debug) console.log("Bracket amount (non inc) " + r);
//                        }
//                    } else {
//                        if (debug) console.log("Full bracket: ", partBracket, " inc: ", inc);
//                        if (inc) {
//
//                            if (bracketAmount > cap && cap > 0) bracketAmount = cap;
//                            let percentValue = rounding * Math.round((bracketAmount * (val / 100)) / rounding);
//
//                            if (r > cap && cap > 0) r = cap;
//                            if (subtractive) { r /= (1 + (val / 100)); }
//                            r += percentValue;
//                            if (debug) console.log("add full bracket... bracketAmount: ", bracketAmount, percentValue);
//                            if (debug) console.log("add full bracket... ", r);
//
//                        }
//                    }
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
//    if (debug) console.log("final amount: ", r, Math.round(r * 100) / 100);
//    return Math.round(r * 100) / 100;
//}
//
//
