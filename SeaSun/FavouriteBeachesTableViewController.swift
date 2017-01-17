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
    
    // Secciones
    var sections: [String]? = []
    
    // Filas
    var rows: [[String]]? = []
    
    // Indice para cada zona
    var rowsIndex: [[Int]]? = []
    
    // Titulo de la vista
    let favTableViewTitle = "Favourite Beaches"
    
    // Variable para CoreData
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    @IBOutlet var favouritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Si existen playas favoritas
        if favouriteBeaches != nil {
            getFavouriteBeaches()
            favBeachesToArray()
        }
        prepareTableView()
        self.navigationItem.title = self.favTableViewTitle

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.rows?[section].count)!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections?[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (sections?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.favouritesTableView.dequeueReusableCell(withIdentifier: "favCell")!
            as UITableViewCell
        cell.textLabel?.text = (self.rows?[indexPath.section][indexPath.row])!
        // Indicador del final
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "disclosureBlack"))
        // Color de la celda
        cell.backgroundColor = UIColor.seaSunBlue
        // Estilo de seleccion
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Presentamos el Main.storyboard
        let storyboard = self.storyboard
        // Inicializamos el view cotroller de este storyboard y pasamos las variables
        let nextView: DetailBeachViewController = storyboard?.instantiateViewController(withIdentifier: "DetailBeachViewController") as! DetailBeachViewController
        nextView.beach = self.favouriteBeaches?[(self.rowsIndex?[indexPath.section][indexPath.row])!]
        // Inicializamos el view controller y le pasamos el VC
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    // Indica que se pueden editar las filas
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Quitamos la playa de favoritos primero
        let beachIndex = self.rowsIndex?[indexPath.section][indexPath.row]
        deleteFavBeachFromCoreData(to: favouriteBeaches?[beachIndex!])
        // Reiniciamos los arrays
        favBeachesToArray()
        // Reiniciamos la tabla
        self.favouritesTableView.reloadData()
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
    
    private func deleteFavBeachFromCoreData(to favBeach: Beach?) {
        managedObjectContext?.performAndWait {
            let fetchRequest = NSFetchRequest<Beach>(entityName: "Beach")
            fetchRequest.predicate = NSPredicate(format: "webCode == %@", (favBeach?.webCode)!)
            do {
                var managedBeach = try self.managedObjectContext?.fetch(fetchRequest)
                managedBeach?[0].fav = false
                try self.managedObjectContext?.save()
                
            } catch let error{
                print("Error retrieve beaches: \(error)")
            }
        }
    }
    
    // En esta funcion rellenamos los arrays de String con las secciones,
    // filas y ademas especificamos que indice tiene cada elemento segun
    // donde este
    private func favBeachesToArray(){
        var currentCity: String?
        var province: String?
        var rowsInSection: [String]? = []
        var count = 0
        var indexInSection: [Int]? = []
        for beach in self.favouriteBeaches! {
            if currentCity != nil {
                if beach.city == currentCity! {
                    rowsInSection?.append(beach.name!)
                    indexInSection?.append(count)
                } else {
                    if let index = self.sections?.index(of: beach.city!) {
                        self.rows?[index].append(beach.name!)
                        self.rowsIndex?[index].append(count)
                        province = beach.beachZone?.province
                    } else {
                        self.sections?.append(currentCity! + " - " + province!)
                        currentCity = beach.city!
                        self.rows?.append(rowsInSection!)
                        rowsInSection?.removeAll()
                        rowsInSection?.append(beach.name!)
                        self.rowsIndex?.append(indexInSection!)
                        indexInSection?.removeAll()
                        indexInSection?.append(count)
                        
                    }
                }
            } else {
                currentCity = beach.city!
                province = beach.beachZone?.province
                rowsInSection?.append(beach.name!)
                indexInSection?.append(count)
            }
            count += 1
        }
        province = favouriteBeaches?.last?.beachZone?.province
        self.sections?.append(currentCity! + " - " + province!)
        self.rows?.append(rowsInSection!)
        self.rowsIndex?.append(indexInSection!)
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
