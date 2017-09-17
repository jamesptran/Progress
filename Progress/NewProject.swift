//
//  NewProject.swift
//  Progress
//
//  Created by James Tran on 9/2/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol AddTaskToProject {
    func addToProject(_ task: Task)
}

class NewProjectViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, AddTaskToProject {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectTitleField: UITextField!
    var newTaskList : [Task] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(newTaskList)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParentViewController {
            // Perform when popping view controller to parent (main)
            clearDanglingTasks()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newTaskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectTaskCell") as! NewProjectTaskCell
        
        cell.task = newTaskList[indexPath.row]
        
        return cell
    }
    
    func addToProject(_ task: Task) {
        self.newTaskList.append(task)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.newTaskList[indexPath.row])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            
            self.newTaskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        if projectTitleField.text == "" {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        debugPrintCoreData()
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let projectEntity = NSEntityDescription.entity(forEntityName: "Project", in: managedContext)!
        let project = Project(entity: projectEntity, insertInto: managedContext)
        
        project.setValue(projectTitleField.text, forKeyPath: "name")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        for task in newTaskList {
            project.addToHaveTasks(task)
            print("add to project finished")
        }
        debugPrintCoreData()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewProjectToNewTask" {
            if let viewController = segue.destination as? NewTaskViewController {
                viewController.delegate = self
            }
        }
    }
    
}


class NewProjectTaskCell : UITableViewCell {
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var daysLastLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var taskProgressBar: UIProgressView!
    @IBOutlet weak var impPtsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var task : Task? = nil {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            
            self.taskNameLabel.text = task?.name ?? "N/A"
            
            let startDate = (task?.startDate as Date?) ?? Date(timeIntervalSince1970: 0)
            let timeIntervalFromDays = TimeInterval( Int((task?.daysLast) ?? 0) * 24 * 3600)
            let endDate = Date(timeInterval: timeIntervalFromDays, since: startDate)
            let now = Date(timeIntervalSinceNow: 0)
            
            var daysLeft : Int = Int(round(endDate.timeIntervalSinceNow / 3600 / 24))
            var percentCompleted : Double = 1.0 - Double(daysLeft) / (timeIntervalFromDays / 3600 / 24)
            
            if startDate > now {
                daysLeft = Int((task?.daysLast)!)
                percentCompleted = 0
            }
            
            if endDate < now {
                daysLeft = 0
                percentCompleted = 1.0
            }
            
            self.taskProgressBar.progress = Float(percentCompleted)
            self.startDateLabel.text = dateFormatter.string(from: startDate)
            self.daysLastLabel.text = "\(daysLeft) days left"
            
            if (task?.isCompleted)! {
                self.statusLabel.text = "Status: Finished"
                self.taskProgressBar.tintColor = .green
            } else {
                if daysLeft == 0 {
                    self.statusLabel.text = "Status: Overdue"
                    self.taskProgressBar.tintColor = .yellow
                    
                }
                if Int((task?.daysLast)!) == daysLeft {
                    self.statusLabel.text = "Status: Pending"
                    self.taskProgressBar.tintColor = .gray
                }
                if Int((task?.daysLast)!) > daysLeft && daysLeft != 0 {
                    self.statusLabel.text = "Status: Ongoing"
                    self.taskProgressBar.tintColor = .green
                }
            }
            
            
            self.endDateLabel.text = dateFormatter.string(from: endDate)
            self.impPtsLabel.text = String(format: "%i pts", (task?.impPts) ?? 0)
        }
    }
    
}
