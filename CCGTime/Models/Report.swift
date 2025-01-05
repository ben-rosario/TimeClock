//
//  Report.swift
//  CCGTime
//
//  Created by ben on 12/28/24.
//
//  Creates a .xlsx file for a given department for a given date range.
//  Once the file is saved the Files app is opened to the /Documents folder of the app.

import Foundation
import xlsxwriter
import Combine
import SwiftUI


// Int returned is from 1 (monday) to 7 (sunday)
extension Date {
    func dayNumberOfWeek() -> Int? {
        // This function will return 1 (sunday) and 7 (saturday), so we need to adjust
        let initialInt = Calendar.current.dateComponents([.weekday], from: self).weekday!
        
        if initialInt == 1 {
            return 7
        } else {
            return initialInt - 1
        }
    }
    
    // Allow you to find the difference between two dates, returned as a TimeInterval
    // Use by subtracting two dates: (timeDifference = Date1 - Date2)
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
            return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
        }
}

class Report {
    
    @Published var completed = false
    @Published var progress: Double
    
    public let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private let startDate: Date
    private let endDate: Date
    private let dept: String
    private let fileName: String
    private var deptModel: DepartmentModel
    private var wb: Workbook
    private var ws: Worksheet
    
    private var reportHeaderFormat: Format
    private var reportTitleFormat: Format
    private var weeklyTitleFormat: Format
    private var reportDataFormat: Format
    private var reportHeaderDateFormat: Format
    private var reportMoneyFormat: Format
    private var reportGrandTotalTitleFormat: Format
    private var reportSumFormat: Format
    private var reportMoneyFormatBold: Format
    
    private var row = 0
    private var col = 0
    
    public func isCompleted() -> Bool {
        return self.completed 
    }
    
    init (start startDate: Date, end endDate: Date, for dept: String, name: String, deptModel :DepartmentModel) async {
        
        self.startDate = startDate
        self.endDate = endDate
        self.dept = dept
        self.deptModel = deptModel
        self.fileName = "\(name).xlsx"
        self.completed = false
        self.progress = 0.0
        
        // Create workbook and worksheet
        self.wb = Workbook(name: fileName)
        self.ws = self.wb.addWorksheet(name: "Worksheet")
        
        // Create Formats
        self.reportTitleFormat = wb.addFormat()
        self.weeklyTitleFormat = wb.addFormat()
        self.reportHeaderFormat = wb.addFormat()
        self.reportHeaderDateFormat = wb.addFormat()
        self.reportDataFormat = wb.addFormat()
        self.reportMoneyFormat = wb.addFormat()
        self.reportGrandTotalTitleFormat = wb.addFormat()
        self.reportSumFormat = wb.addFormat()
        self.reportMoneyFormatBold = wb.addFormat()
        
        self.create()
        await self.write()
        self.save()
    }
    
    private func create() {
        
        // Set column widths for known header columns
        self.ws.column([1,12], width: 18.0)
        
        /* Edit format types */
        
        // Report Title Formatting (e.g. 'ExampleDepartment Report')
        reportTitleFormat.bold()
        reportTitleFormat.font(size: 20)
        reportTitleFormat.font(name: "Helvetica")
        
        // Weekly Title Formatting (e.g. 'Report starting 10/20/2020')
        weeklyTitleFormat.bold()
        weeklyTitleFormat.font(size: 14)
        weeklyTitleFormat.font(name: "Arial")
        
        // Report Header Formatting for first row of each week's report
        reportHeaderFormat.bold()
        reportHeaderFormat.font(size: 12)
        reportHeaderFormat.font(name: "Arial")
        reportHeaderFormat.align(horizontal: .center)
        
        // Report Data Formatting (e.g. '8.0')
        reportDataFormat.font(size: 11)
        reportDataFormat.font(name: "Arial")
        reportDataFormat.border(style: .thin)
        reportDataFormat.set(num_format: "0.00")
        reportDataFormat.align(horizontal: .center)
        // Report Money Formatting (e.g. '$1.00')
        reportMoneyFormat.font(size: 11)
        reportMoneyFormat.font(name: "Arial")
        reportMoneyFormat.border(style: .thin)
        reportMoneyFormat.set(num_format: "$0.00")
        
        // Same as reportMoneyFormat, but bold
        reportMoneyFormatBold.font(size: 11)
        reportMoneyFormatBold.font(name: "Arial")
        reportMoneyFormatBold.border(style: .thin)
        reportMoneyFormatBold.set(num_format: "$0.00")
        reportMoneyFormatBold.bold()
        
        // Report Grand Total Title Formatting
        reportGrandTotalTitleFormat.bold()
        reportGrandTotalTitleFormat.font(size: 11)
        reportGrandTotalTitleFormat.font(name: "Arial")
        reportGrandTotalTitleFormat.border(style: .thin)
        reportGrandTotalTitleFormat.set(num_format: "0.00")
        
        // Report Sum Total Formatting
        reportSumFormat.bold()
        reportSumFormat.font(size: 11)
        reportSumFormat.font(name: "Arial")
        reportSumFormat.border(style: .thin)
        reportSumFormat.align(horizontal: .center)
        reportSumFormat.set(num_format: "0.00")
        
        // Change the directory to the app's default Documents path
        FileManager.default.changeCurrentDirectoryPath(documentsUrl.path)
         
        ws.write(.string("\(dept) Report"), [0,0], format: reportTitleFormat)
        col+=1
    }
    
    private func write() async {
        
        // Write introduction for the week
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        dateFormat.timeStyle = .none
        dateFormat.timeZone = .current
        
        var weekStartDate = startDate
        var dateString = ""
        
        let components = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: endDate)
        let numWeeks = components.weekOfYear!
        print("numWeeks: \(numWeeks)")
        let progressIncrements = 1.0/Double(numWeeks)
        
        // While-loop to write the weekly graph
        while weekStartDate <= endDate {
            row+=4
            dateString = dateFormat.string(from: weekStartDate)
            ws.write(.string("Week Beginning \(dateString)"), [row,col], format: weeklyTitleFormat)
            row+=2
            
            await self.writeWeeklyGraph(starting: weekStartDate)
            
            // Increment currentDate by a dynamic amount of days
            if weekStartDate.dayNumberOfWeek()! == 1 {
                weekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: weekStartDate)!
            } else {
                let incrementAmt = 8-weekStartDate.dayNumberOfWeek()!
                weekStartDate = Calendar.current.date(byAdding: .day, value: incrementAmt, to: weekStartDate)!
            }
            print("Progress: \(self.progress)")
            self.progress += progressIncrements
        }
    }
    
    private func save() {
        wb.close()
        self.progress = 1.0
        self.completed = true
        self.openFilesApp(to: documentsUrl)
    }
    
    private func writeWeeklyGraph(starting beginningDate: Date) async {
        let initialCol = col
        
        // Represents the number of date columns (Mon, Tues, Weds, etc.) that will be in this week's report
        let dateColumns: Int
        if self.reportEndsThisWeek(startDate: beginningDate) {
            let endingDayOfWeek = endDate.dayNumberOfWeek()!
            dateColumns = (endingDayOfWeek - beginningDate.dayNumberOfWeek()!) + 1
        } else if beginningDate.dayNumberOfWeek()! == 1 {
            dateColumns = 7
        } else {
            dateColumns = 8 - beginningDate.dayNumberOfWeek()!
        }
        
        if dateColumns == 0 { return }
        
        // employeeWorked is the source of truth about the order of the employees in the timesheet
        // employeeWorked[0] will always be the first employee displayed for a given week
        let employeesWorked: [Employee] = await deptModel.getEmployeesWorkedForWeek(week: beginningDate, for: self.dept)
        
        
        self.writeEmployeeIds(week: beginningDate, employees: employeesWorked)
        col+=1
        
        await self.writeEmployeeNames(week: beginningDate, employees: employeesWorked)
        col+=1
        
        let firstDayCol=col
        self.writeDaysOfWeek(starting: beginningDate, days: dateColumns)
        col+=dateColumns
        
        self.ws.write(.string("Total Hrs Worked"), [row,col], format: reportHeaderFormat)
        col+=1
        
        self.ws.write(.string("Wage"), [row,col], format: reportHeaderFormat)
        col+=1
        
        self.ws.write(.string("Total Pay"), [row,col], format: reportHeaderFormat)
        col=firstDayCol
        row+=1
        
        
        await self.writeWorkedHours(for: employeesWorked, on: beginningDate, days: dateColumns)
        col+=dateColumns
        
        // write sum equations for total hours worked for each employee
        self.writeTotalHoursWorked(for: employeesWorked, days: dateColumns)
        col+=1
        
        //
        self.writeEmployeeWages(for: employeesWorked, days: dateColumns)
        col+=1
        
        //
        self.writeTotalPayFormula(for: employeesWorked)
        // reset row,col position
        col = firstDayCol-1
        
        self.writeGrandTotalFormula(employeesCount: employeesWorked.count, dateColumns: dateColumns)
        
        col = initialCol
    }
    
    private func writeGrandTotalFormula(employeesCount count: Int, dateColumns dates: Int) {
        if count <= 0 { return }
        
        row+=count
        ws.write(.string("All Employees"), [row,col], format: reportGrandTotalTitleFormat)
        col+=1
        
        let firstRow = (row-count)+1
        let lastRow = row
        
        var currentCol: String
        
        for _ in 1...(dates+1) {
            currentCol = self.findColLetter(col: col)
            // Add 1 to firstRow to account for the 0th row
            let formula = "=SUM(\(currentCol)\(firstRow):\(currentCol)\(lastRow))"
            ws.write(.formula(formula), [row,col], format: reportSumFormat)
            col+=1
        }
        
        ws.write(.string("N/A"), [row,col], format: reportGrandTotalTitleFormat.align(horizontal: .center))
        
        col+=1
        currentCol = self.findColLetter(col: col)
        let formula = "=SUM(\(currentCol)\(firstRow):\(currentCol)\(lastRow))"
        ws.write(.formula(formula), [row,col], format: reportMoneyFormatBold)
        
        col-=(4+dates)
        row+=3
    }
    
    private func writeTotalPayFormula(for emps: [Employee]) {
        let initialCol = col
        let initialRow = row
        
        if emps.isEmpty {
            ws.write(.number(0), [row,col], format: reportMoneyFormat)
        } else {
            for _ in emps {
                let hrsColumn = self.findColLetter(col: col - 2)
                let wageColumn = self.findColLetter(col: col - 1)
                let formula = "=(\(hrsColumn)\(row+1)*\(wageColumn)\(row+1))"
                ws.write(.formula(formula), [row,col], format: reportMoneyFormat)
                row+=1
            }
        }
        
        col = initialCol
        row = initialRow
    }
    
    private func writeEmployeeWages(for emps: [Employee], days: Int) {
        let initialRow = row
        let initialCol = col
        
        if emps.isEmpty {
            ws.write(.string("N/A"), [row,col], format: reportGrandTotalTitleFormat.align(horizontal: .center))
        } else {
            for emp in emps {
                ws.write(.number(emp.wage), [row,col], format: reportDataFormat)
                row+=1
            }
        }
        row = initialRow
        col = initialCol
    }
    
    private func writeTotalHoursWorked(for emps: [Employee], days: Int) {
        let initialCol = col
        let initialRow = row
        // explain
        let totalHrsCol: String = self.findTotalHrsCol(days)
        
        if emps.isEmpty {
            ws.write(.number(0), [row,col], format: reportDataFormat)
        } else {
            for _ in emps {
                // Have to add 1 to row var because 0 is the first row for xlsxwriter.swift,
                // but 1 is the first row when Excel is interpreting the formula code
                let formula: String = "=SUM(D\(row+1):\(totalHrsCol)\(row+1))"
                ws.write(.formula(formula), [row,col], format: reportDataFormat)
                row+=1
            }
        }
        col = initialCol
        row = initialRow
    }
    
    // Only works for Ints 0 through 25
    private func findColLetter(col int: Int) -> String {
        let alphabet=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

        return alphabet[int]
    }
    
    private func findTotalHrsCol(_ days: Int) -> String {
        switch days {
        case 1: return "D"
        case 2: return "E"
        case 3: return "F"
        case 4: return "G"
        case 5: return "H"
        case 6: return "I"
        case 7: return "J"
        default: return "D"
        }
    }
    
    private func writeWorkedHours(for employees: [Employee], on givenDate: Date, days: Int) async {
        if givenDate > endDate { return }
        
        let initialCol = col
        let initialRow = row
        
        var currentDate = givenDate
        
        if employees.isEmpty {
            for _ in 1...days {
                ws.write(.number(0.0), [row,col], format: reportDataFormat)
                col+=1
            }
        } else {
            for _ in 1...days {
                
                for employee in employees {
                    let hoursWorked = await deptModel.hoursWorked(for: employee, on: currentDate)
                    ws.write(.number(hoursWorked), [row,col], format: reportDataFormat)
                    row+=1
                }
                // Now go to the next day of the report and reset the row
                col+=1
                row = initialRow
                // Increment date by 1 day
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
        
        col=initialCol
        row=initialRow
    }
    
    private func writeDaysOfWeek(starting startDate: Date, days: Int) {
        let initialCol = col
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone = .current
        dateFormat.timeStyle = .none
        dateFormat.dateStyle = .short
        
        var currentDate = startDate
        
        for _ in 1...days {
            
            if currentDate > endDate { break }
            // dayName: 'Mon', 'Tues', 'Weds', etc
            let dayName = self.getDayName(currentDate.dayNumberOfWeek()!)
            // shortDate: '12/31/2000'
            let shortDate = dateFormat.string(from: currentDate)
            
            ws.write(.string("\(dayName) \(shortDate)"), [row,col], format: reportHeaderFormat)
            
            //advance currentDate object by 1 day
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            col+=1
        }
        
        col = initialCol
    }
    
    private func reportEndsThisWeek(startDate date: Date) -> Bool {
        if date >= endDate { return true }
        
        let startingDayOfWeek = date.dayNumberOfWeek()!
        let increment = 7 - startingDayOfWeek
        let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: increment, to: date)!
        
        if lastDayOfWeek >= endDate { return true }
        else { return false }
        
    }
    
    // Returns a shortened form of the day's name (e.g. "Mon", "Tues", "Weds"...)
    private func getDayName(_ num: Int) -> String {
        switch num {
        case 1: return "Mon"
        case 2: return "Tues"
        case 3: return "Weds"
        case 4: return "Thurs"
        case 5: return "Fri"
        case 6: return "Sat"
        case 7: return "Sun"
        default:
            return ""
        }
        
    }
    
    @MainActor private func writeEmployeeNames(week date: Date, employees: [Employee]) {
        let initialRow = row
        
        ws.write(.string("Employee Name"), [row,col], format: reportHeaderFormat)
        row+=1
        
        if employees.isEmpty {
            ws.write(.string("None"), [row,col], format: reportDataFormat.align(horizontal: .center))
        } else {
            for employee in employees {
                let empName = deptModel.getName(employee.employeeId)
                ws.write(.string(empName), [row,col], format: reportDataFormat)
                row+=1
            }
        }
        row = initialRow
    }
    
    private func writeEmployeeIds(week date: Date, employees: [Employee]) {
        let startingRow = row
        
        ws.write(.string("Employee #"), [row,col], format: reportHeaderFormat)
        row+=1
        
        if employees.isEmpty {
            ws.write(.string("No employees found"), [row,col], format: reportDataFormat)
        } else {
            for employee in employees {
                ws.write(.string(employee.employeeId), [row,col], format: reportDataFormat)
                row+=1
            }
            // Reset row position
        }
        row = startingRow
    }
    
    private func openFilesApp(to url: URL) {
        //let documentsUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let path = url.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
        if let url = URL(string: path) {
            UIApplication.shared.open(url)
        }
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
}
