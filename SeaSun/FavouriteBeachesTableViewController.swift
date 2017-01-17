//
//  FavouriteBeachesTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class FavouriteBeachesTableViewController: UITableViewController {
    
    // Playas favoritas
    var favouriteBeaches: [Beach]?
    
    // Titulo de la vista
    let favTableViewTitle = "Favourite Beaches"
    
    // Variable para CoreData
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    @IBOutlet var favouritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFavouriteBeaches()
        prepareTableView()
        self.navigationItem.title = self.favTableViewTitle

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    private func prepareTableView() {
        self.favouritesTableView.delegate = self
        self.favouritesTableView.dataSource = self
        self.favouritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "favCell")
        // Cambiamos color separador de la tabla y hacemos que llegue de lado a lado
        self.favouritesTableView.separatorColor = UIColor.black
        self.favouritesTableView.separatorInset.left = 0
        self.favouritesTableView.separatorInset.right = 0
        self.favouritesTableView.backgroundColor = UIColor.seaSunBlue
        // Mostrar solo las celdas que se ven
        let footerView = UIView()
        self.favouritesTableView.tableFooterView = footerView
    }
    
    private func getFavouriteBeaches() {
        managedObjectContext?.performAndWait {
            let fetchRequest = NSFetchRequest<Beach>(entityName: "Beach")
            fetchRequest.predicate = NSPredicate(format: "fav == %@", NSNumber(booleanLiteral: true))
            do {
                self.favouriteBeaches = try self.managedObjectContext?.fetch(fetchRequest)
                //zonesToArray = self.zonesToArray(inZones: zones)
                print(self.favouriteBeaches?.count ?? -1)
                
            } catch let error{
                print("Error retrieve beaches: \(error)")
            }
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
