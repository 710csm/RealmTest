//
//  ViewController.swift
//  RealmTest
//
//  Created by 최승명 on 2020/11/15.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var stuffTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var stuffPrint: UILabel!
    @IBOutlet weak var priceePrint: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var items: Results<ShoppingList>?
    var realm: Realm?
    var notificationToken: NotificationToken?
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken?.invalidate()
    }
    
    //MARK: Action method
    @IBAction func add(_ sender: Any) {
        try! realm?.write{
            realm?.add(inputData(database: ShoppingList()))
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        do{
            try realm?.write {
                realm?.delete(items!)
            }
        }catch{
            print("Error")
        }
    }
    
    @IBAction func read(_ sender: Any) {
        print(realm?.objects(ShoppingList.self))
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
                stuffPrint.text = list.name
                priceePrint.text = list.price
            })
        }
    }
    
}

class ShoppingList: Object{
    @objc dynamic var name = ""
    @objc dynamic var price = ""
}
