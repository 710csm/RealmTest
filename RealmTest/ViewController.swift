//
//  ViewController.swift
//  RealmTest
//
//  Created by 최승명 on 2020/11/15.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var stuffTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var items: Results<ShoppingList>?
    var realm: Realm?
    var notificationToken: NotificationToken?
    var readItemName = [String]()
    var readItemPrice = [String]()
    
    //MARK: override func method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try? Realm()
        
        items = realm?.objects(ShoppingList.self)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        notificationToken = items?.observe({ (change) in
            print("change : ", change)
            self.tableView.reloadData()
        })
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken?.invalidate()
    }
    
    //MARK: func method
    deinit{
        notificationToken?.invalidate()
    }
    
    func inputData(database: ShoppingList) -> ShoppingList{
        if let name = stuffTextField.text {
            database.name = name
        }
        
        if let price = priceTextField.text {
            database.price = price
        }
        return database
    }
    
    func deleteData(){
       
    }

    
    //MARK: Action method
    @IBAction func add(_ sender: Any) {
        try! realm?.write{
            realm?.add(inputData(database: ShoppingList()))
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let tempObject = ShoppingList()
        tempObject.name = stuffTextField.text ?? ""
        tempObject.price = priceTextField.text ?? ""
        
        do{
            try realm?.write {
                realm?.delete(tempObject)
            }
        }catch{
            print("Error")
        }
    }
    
    @IBAction func read(_ sender: Any) {
        let result = realm?.objects(ShoppingList.self).sorted(byKeyPath: "name", ascending: true)
        readItemName = result?.value(forKey: "name") as! [String]
        readItemPrice = result?.value(forKey: "price") as! [String]
        tableView.reloadData()
        
        print(result ?? "값 없음")
        
        
    }
    
    @IBAction func update(_ sender: Any) {
        try! realm?.write{
            guard let items = items else {
                return
            }
            
            items.forEach({ (list) in
                if let name = stuffTextField.text, let price = priceTextField.text {
                    if list.name == name {
                        list.name = name
                        list.price = price
                    }
                }
            })
        }
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readItemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stuffInfo", for: indexPath)
        cell.textLabel?.text = readItemName[indexPath.row]
        cell.detailTextLabel?.text = readItemPrice[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            readItemName.remove(at: indexPath.row)
            readItemPrice.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let tempObject = ShoppingList()
            tempObject.name = readItemName[indexPath.row]
            tempObject.price = readItemPrice[indexPath.row]
            
            do{
                try realm?.write {
                    realm?.delete(tempObject)
                }
            }catch{
                print("Error")
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // 삭제 시 "Delete" 대신 "삭제"로 표시
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String {
        return "삭제"
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = readItemName[fromIndexPath.row]
        readItemName.remove(at: fromIndexPath.row)
        readItemName.insert(itemToMove, at: to.row)
        
        readItemPrice.remove(at: fromIndexPath.row)
        readItemPrice.insert(itemToMove, at: to.row)
    }
    
}

class ShoppingList: Object{
    @objc dynamic var name = ""
    @objc dynamic var price = ""
}
