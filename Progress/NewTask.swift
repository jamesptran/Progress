//
//  NewTask.swift
//  Progress
//
//  Created by James Tran on 9/2/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewTaskViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var delegate : AddTaskToProject? = nil
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var daysLastField: UITextField!
    @IBOutlet weak var impPtsField: UITextField!
    
    let impPtsChoice : [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        let datePickerView = UIDatePicker()
        
        pickerView.delegate = self
        
        impPtsField.inputView = pickerView
        startDateField.inputView = datePickerView
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(NewTaskViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        impPtsField.delegate = self
        startDateField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.placeholder == "Pts" && textField.text == "" {
            textField.text = "1"
        }
        
        if textField.placeholder == "Estimated date" && textField.text == "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            textField.text = dateFormatter.string(from: Date(timeIntervalSinceNow: 0))
        }
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        
        if taskNameField.text == "" || startDateField.text == "" || daysLastField.text == "" || impPtsField.text == "" {
            return
        }
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
        let task = Task(entity: entity, insertInto: managedContext)
        
        task.setValue(taskNameField.text, forKeyPath: "name")
        
        let startDate = dateFormatter.date(from: startDateField.text ?? "Jan 01, 1970")
        task.setValue(startDate, forKeyPath: "startDate")
        task.setValue(Int(daysLastField.text ?? "0"), forKeyPath: "daysLast")
        task.setValue(Int(impPtsField.text ?? "0"), forKeyPath: "impPts")
        task.setValue(false, forKeyPath: "isCompleted")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        delegate?.addToProject(task)
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return impPtsChoice.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(impPtsChoice[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        impPtsField.text = String(impPtsChoice[row])
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        startDateField.text = dateFormatter.string(from: sender.date)
    }
}
