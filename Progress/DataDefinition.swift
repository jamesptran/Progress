//
//  DataDefinition.swift
//  Progress
//
//  Created by James Tran on 9/2/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Project {
    func percent() -> Double {
        let taskList : [Task] = self.haveTasks?.allObjects as! [Task]
        
        var totalPts : Int32 = 0
        var completedPts : Int32 = 0
        for task in taskList {
            if task.isCompleted {
                completedPts += task.impPts
            }
            totalPts += task.impPts
        }
        
        if totalPts == 0 {
            return 0
        }
        
        // Make sure percent function returns in the form of 0.xx
        let percent : Double = round(Double(completedPts) / Double(totalPts) * 100)
        return percent / 100.0
    }
    
    func startDate() -> Date {
        let taskList : [Task] = self.haveTasks?.allObjects as! [Task]
        var returnDate : Date? = taskList.first?.startDate as Date?
        
        if returnDate == nil {
            return Date(timeIntervalSince1970: 0)
        }
        
        for task in taskList {
            
            if task.startDate?.compare(returnDate!) == ComparisonResult.orderedAscending {
                returnDate = task.startDate! as Date
            }
        }
        
        return returnDate!
    }
    
    func endDate() -> Date {
        let taskList : [Task] = self.haveTasks?.allObjects as! [Task]
        var returnDate : Date = Date(timeIntervalSince1970: 0)
        
        for task in taskList {
            let endDate = Date(timeInterval: TimeInterval(task.daysLast * 24 * 3600), since: task.startDate as? Date ?? Date(timeIntervalSince1970: 0))
            if endDate > returnDate {
                returnDate = endDate
            }
        }
        
        return returnDate
    }
    
    func totalPts() -> Int {
        let taskList : [Task] = self.haveTasks?.allObjects as! [Task]
        var sumPts : Int = 0
        for task in taskList {
            sumPts += Int(task.impPts)
        }
        
        return sumPts
    }
    
    func completedPts() -> Int {
        let taskList : [Task] = self.haveTasks?.allObjects as! [Task]
        var compPts : Int = 0
        for task in taskList {
            if task.isCompleted {
                compPts += Int(task.impPts)
            }
        }
        
        return compPts
    }
}

extension Task {
    func endDate() -> Date {
        let start : Date = self.startDate! as Date
        let daysLastTimeInterval : TimeInterval = Double(self.daysLast) * 3600 * 24
        return Date(timeInterval: daysLastTimeInterval, since: start)
    }
}

func clearDanglingTasks() {
    var taskList : [Task] = []
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
    
    do {
        taskList = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    for task in taskList {
        if task.forProject == nil {
            // remove task
            managedContext.delete(task)
        }
    }
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }

}


func debugPrintCoreData() {
    var taskList : [Task] = []
    var projectList : [Project] = []
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
    
    do {
        taskList = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    let fetchRequest2 = NSFetchRequest<Project>(entityName: "Project")
    
    do {
        projectList = try managedContext.fetch(fetchRequest2)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    print(taskList)
    print(projectList)
}

