//
//  ViewController.swift
//  Progress
//
//  Created by James Tran on 8/17/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import UIKit
import CoreData


class ProgressMain: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var projectList : [Project] = []
    let defaults:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show displayingProject
        // TODO: Use NSUserDefault to set the displayingProject
        
        let noTutorial:Bool = defaults.bool(forKey: "DontShowTutorial" )
        if !noTutorial {
            self.performSegue(withIdentifier: "MainToTutorialSegue", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
        
        do {
            projectList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
        clearDanglingTasks()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainProjectCell") as! MainProgressCell
        
        cell.project = projectList[indexPath.row]
        
        return cell
    }
    
    
    @IBAction func newProjectButtonTouched(_ sender: Any) {
        print("New Project Button Touched")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToProjectDetail" {
            if let viewController = segue.destination as? ProjectDetailViewController {
                viewController.project = sender as? Project
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.projectList[indexPath.row])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            
            self.projectList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MainToProjectDetail", sender: projectList[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}


class MainProgressCell : UITableViewCell {
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var shouldCompleteProgressBar: UIProgressView!
    
    var project : Project = Project() {
        didSet {
            var shouldCompletePts : Int = 0
            var totalPts : Int = 0
            var completedPts : Int = 0
            for task in project.haveTasks?.allObjects as! [Task] {
                totalPts += Int(task.impPts)
                if task.endDate() < Date(timeIntervalSinceNow: 0) {
                    shouldCompletePts += Int(task.impPts)
                }
                if task.isCompleted {
                    completedPts += Int(task.impPts)
                }
            }
            
            self.projectLabel.text = project.name
            self.progressBar.progress = Float(project.percent())
            
            if totalPts == 0 {
                self.shouldCompleteProgressBar.progress = 1
            } else {
                self.shouldCompleteProgressBar.progress = Float(shouldCompletePts) / Float(totalPts)
            }
            
            if shouldCompletePts <= completedPts {
                shouldCompleteProgressBar.tintColor = .green
            }
            if shouldCompletePts > completedPts {
                shouldCompleteProgressBar.tintColor = .yellow
                if shouldCompletePts == totalPts {
                    shouldCompleteProgressBar.tintColor = .red
                }
            }
            
        }
    }
}
