//
//  ViewController.swift
//  IOS Build
//
//  Created by Adeleye Ayodeji on 06/08/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //private constant table with anonymous closure pattern
    private let table: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //declare items for arrays of strings
    var items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load the previously save array text from the user device
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        //set the table delegate for single click of table cell
        table.delegate = self
        //title
        title = "Todo List"
        //add sub view table
        view.addSubview(table)
        //table data source
        table.dataSource = self //UITableViewDataSource
        //add right button bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    //didTapAdd
    @objc private func didTapAdd() {
        //add alert controller
        let alert = UIAlertController(title: "New Item", message: "Enter new to do list item!", preferredStyle: .alert)
        //add text field input
        alert.addTextField{ field in
            //pass the field
            field.placeholder = "Enter item..."
        }
        
        //add alert action button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //add alert action two
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {[weak self](_) in
            //check if the field is text fields and select the first one
            if let field = alert.textFields?.first{
                //check if field is text and check if not empty
                if let text = field.text, !text.isEmpty {
                    //dispatch queue to main thread and also add 'weak self' to the loop to avoid memory leak
                    DispatchQueue.main.async {
                        // append the new item text
                        self?.items.append(text)
                        //save the item to the user device
                        let saveitemArray = self?.items
                        //save the data to the device using UserDefaults
                        UserDefaults.standard.setValue(saveitemArray, forKey: "items")
                        self?.table.reloadData()
                    }
                }
            }
        }))
        
        //present alert
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    //Edit cell on click edit
    func editItem(at indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        
        // Create a UIAlertController as an alert pop-up
        let alertController = UIAlertController(title: "Edit Item", message: "Enter the updated item details:", preferredStyle: .alert)

        // Add a text field to the alert controller for the user to edit the item
        alertController.addTextField { textField in
            textField.placeholder = "Edit item name"
            textField.text = selectedItem // Pre-fill the text field with the existing item's name
        }

        // Add an "Update" action to the alert controller
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            if let updatedText = alertController.textFields?.first?.text {
                // Handle the update action here
                // For example, you can update the item in your data source and reload the table view
                self.items[indexPath.row] = updatedText
                //update saved device data
                UserDefaults.standard.set(self.items, forKey: "items")
                //reload table at row
                self.table.reloadRows(at: [indexPath], with: .automatic)
                //show alert
                
            }
        }
        alertController.addAction(updateAction)

        // Add a "Cancel" action to dismiss the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    // Add this method to handle the click event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           // This method is called when a cell is tapped
           let selectedItem = items[indexPath.row]
           print("Selected item: \(selectedItem)")
           
        // Create a UIAlertController as an action sheet
        let alertController = UIAlertController(title: "Options", message: "Choose an action:", preferredStyle: .actionSheet)

        // Add a "Delete" action to the alert controller
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Handle delete action here
            // For example, you can delete the item from your data source and update the table view
            self.items.remove(at: indexPath.row)
            //update saved device data
            UserDefaults.standard.set(self.items, forKey: "items")
            //update table
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        alertController.addAction(deleteAction)

        // Add an "Edit" action to the alert controller
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            // Handle edit action here
            self.editItem(at: indexPath)
        }
        
        alertController.addAction(editAction)

        // Add a "Cancel" action to dismiss the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller as a popover on iPad and as a sheet on iPhone
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = tableView.cellForRow(at: indexPath)
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
            popoverController.permittedArrowDirections = .any
        }
        present(alertController, animated: true, completion: nil)

        // Deselect the selected row to remove the highlight after the action sheet is dismissed
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //table view for row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the count of items
        return items.count
    }
    
    //table view for label display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //declare constant cell and add a reusable table cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let date = Date()
        let dateFormatter = DateFormatter()
         
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
         
        let result = dateFormatter.string(from: date)
        
        //add table cell text label
        var content = cell.defaultContentConfiguration()
        
        // Configure content.
        content.image = UIImage(systemName: "checkmark")
        content.text = items[indexPath.row]
        content.secondaryText = result

        // Customize appearance.
        content.imageProperties.tintColor = .blue


        cell.contentConfiguration = content
        
        //return the cell
        return cell
    }


}

