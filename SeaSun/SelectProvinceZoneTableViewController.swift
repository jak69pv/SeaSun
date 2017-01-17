//
//  SelectProvinceTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class SelectProvinceZoneTableViewController: UITableViewController {
    
    var bigZone: String?
    
    // Todas las zonas
    var zones: [Zone]?
    
    // Secciones
    var sections: [String]? = []
    
    // Filas
    var rows: [[String]]? = []
    
    // Indice para cada zona
    var rowsIndex: [[Int]]? = []
    
    // Variable para CoreData
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    @IBOutlet var zonesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bigZone
        zonesToArray()
        prepareTableView()

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
        let cell: UITableViewCell = self.zonesTableView.dequeueReusableCell(withIdentifier: "zoneCell")!
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
        let pZone = self.zones?[(self.rowsIndex?[indexPath.section][indexPath.row])!]
        // Inicializamos el view cotroller de este storyboard y pasamos las variables
        let nextView: SelectBeachTableViewController = storyboard?.instantiateViewController(withIdentifier: "SelectBeachTableViewController") as! SelectBeachTableViewController
        nextView.pZone = pZone
        nextView.beaches = pZone?.beaches?.allObjects as! [Beach]?
        // Inicializamos el view controller y le pasamos el VC
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    private func prepareTableView() {
        self.zonesTableView.delegate = self
        self.zonesTableView.dataSource = self
        self.zonesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "zoneCell")
        // Cambiamos color separador de la tabla y hacemos que llegue de lado a lado
        self.zonesTableView.separatorColor = UIColor.black
        self.zonesTableView.separatorInset.left = 0
        self.zonesTableView.separatorInset.right = 0
        self.zonesTableView.backgroundColor = UIColor.seaSunBlue
        // Mostrar solo las celdas que se ven
        let footerView = UIView()
        self.zonesTableView.tableFooterView = footerView
        
    }
    
    // En esta funcion rellenamos los arrays de String con las secciones,
    // filas y ademas especificamos que indice tiene cada elemento segun
    // donde este
    private func zonesToArray(){
        var currentProvince: String?
        var rowsInSection: [String]? = []
        // Variable para indexar las filas aunque esten desordenadas
        var count = 0
        var indexInSection: [Int]? = []
        for zone in self.zones! {
            // Si es la primera vuelta
            if currentProvince != nil {
                // Si seguimos en la misma seccion
                if zone.province == currentProvince! {
                    rowsInSection?.append(zone.pZone!)
                    indexInSection?.append(count)
                } else {
                    // Si era de una seccion que ya existia
                    if let index = self.sections?.index(of: zone.province!) {
                        self.rows?[index].append(zone.pZone!)                        
                        self.rowsIndex?[index].append(count)
                    } else {
                        self.sections?.append(currentProvince!)
                        currentProvince = zone.province!
                        self.rows?.append(rowsInSection!)
                        rowsInSection?.removeAll()
                        rowsInSection?.append(zone.pZone!)
                        self.rowsIndex?.append(indexInSection!)
                        indexInSection?.removeAll()
                        indexInSection?.append(count)
                    }
                }
            } else {
                currentProvince = zone.province!
                rowsInSection?.append(zone.pZone!)
                indexInSection?.append(count)
            }
            count += 1
        }
        self.sections?.append(currentProvince!)
        self.rows?.append(rowsInSection!)
        self.rowsIndex?.append(indexInSection!)
    }
}
