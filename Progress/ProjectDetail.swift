//
//  ProjectDetail.swift
//  Progress
//
//  Created by James Tran on 9/2/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit

class ProjectDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, AddTaskToProject {
    
    var project : Project?
    var taskList : [Task] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var shouldCompletePercentLabel: UILabel!
    @IBOutlet weak var shouldCompleteProgressBar: UIProgressView!
    @IBOutlet weak var alertLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateProgressBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgressBar()
    }
    
    func updateProgressBar() {
        self.taskList = (project?.haveTasks?.allObjects as? [Task]) ?? []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let today = dateFormatter.date(from: dateFormatter.string(from: Date(timeIntervalSinceNow: 0)))

        if let unwrapped = project {
            self.projectLabel.text = unwrapped.name
            var shouldCompletePts : Int = 0
            var totalPts : Int = 0
            var completedPts : Int = 0
            for task in unwrapped.haveTasks?.allObjects as! [Task] {
                totalPts += Int(task.impPts)
                
                if task.endDate() < today! {
                    shouldCompletePts += Int(task.impPts)
                }
                if task.isCompleted {
                    completedPts += Int(task.impPts)
                }
            }
            
            if shouldCompletePts < completedPts {
                alertLabel.text = "You are ahead on schedule! Have a little break."
                shouldCompleteProgressBar.tintColor = .green
            }
            if shouldCompletePts > completedPts {
                alertLabel.text = "You are behind on schedule!"
                shouldCompleteProgressBar.tintColor = .yellow
                if shouldCompletePts == totalPts {
                    alertLabel.text = "It should be finished by now!"
                    shouldCompleteProgressBar.tintColor = .red
                }
            }
            if shouldCompletePts == completedPts {
                alertLabel.text = "You are right on track! Keep up!"
                shouldCompleteProgressBar.tintColor = .green
                if shouldCompletePts == 0 {
                    alertLabel.text = "You are on your first task. Good luck!"
                }
            }
            if completedPts == totalPts {
                alertLabel.text = "The project is completed. Well done!"
                shouldCompleteProgressBar.tintColor = .green
            }
            
            self.progressBar.progress = Float(unwrapped.percent())
            self.percentLabel.text =  String(format: "%.0f%% (\(completedPts)pts/\(totalPts)pts)", unwrapped.percent() * 100)
            shouldCompleteProgressBar.progress = Float(shouldCompletePts) / Float(totalPts)
            let shouldCompletePercent : Float = Float(shouldCompletePts) / Float(totalPts) * 100
            shouldCompletePercentLabel.text = String(format: "%.0f%% (\(shouldCompletePts)pts/\(totalPts)pts)", shouldCompletePercent)
            
            if totalPts == 0 {
                shouldCompleteProgressBar.progress = 1
                shouldCompleteProgressBar.tintColor = .green
                shouldCompletePercentLabel.text = String(format: "%.0f%% (\(shouldCompletePts)pts/\(totalPts)pts)", 100.0)
                alertLabel.text = "There is no task in this project yet."
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewProjectTaskCell") as! NewProjectTaskCell
        
        cell.task = taskList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.taskList[indexPath.row])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            
            self.taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.backgroundColor = .red
        
        let complete = UITableViewRowAction(style: .normal, title: "Complete") { action, index in
            if self.taskList[indexPath.row].isCompleted {
                self.taskList[indexPath.row].isCompleted = false
            } else {
                self.taskList[indexPath.row].isCompleted = true
            }
            tableView.reloadData()
            self.viewDidLoad()
        }
        complete.backgroundColor = .green
        
        if self.taskList[indexPath.row].isCompleted {
            complete.backgroundColor = .orange
            complete.title = "Uncomplete"
        }
        
        return [complete, delete]
    }
    
    func addToProject(_ task: Task) {
        project?.addToHaveTasks(task)
        taskList.append(task)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectDetailToNewTask" {
            if let viewController = segue.destination as? NewTaskViewController {
                viewController.delegate = self
            }
        }
    }
}
