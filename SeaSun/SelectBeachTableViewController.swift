//
//  SelectBeachTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 2/1/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import UIKit

class SelectBeachTableViewController: UITableViewController {
    
    var pZone: Zone?
    
    var beaches: [Beach]?
    
    // Secciones
    var sections: [String]? = []
    
    // Filas
    var rows: [[String]]? = []
    
    // Indice para cada zona
    var rowsIndex: [[Int]]? = []

    @IBOutlet var beachesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (pZone?.province)! + " " + (pZone?.pZone)!
        beachesToArray()
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
        let cell: UITableViewCell = self.beachesTableView.dequeueReusableCell(withIdentifier: "beachCell")!
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
        nextView.beach = self.beaches?[(self.rowsIndex?[indexPath.section][indexPath.row])!]
        // Inicializamos el view controller y le pasamos el VC
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    private func prepareTableView() {
        self.beachesTableView.delegate = self
        self.beachesTableView.dataSource = self
        self.beachesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "beachCell")
        // Cambiamos color separador de la tabla y hacemos que llegue de lado a lado
        self.beachesTableView.separatorColor = UIColor.black
        self.beachesTableView.separatorInset.left = 0
        self.beachesTableView.separatorInset.right = 0
        self.beachesTableView.backgroundColor = UIColor.seaSunBlue
        // Mostrar solo las celdas que se ven
        let footerView = UIView()
        self.beachesTableView.tableFooterView = footerView
    }
    
    // En esta funcion rellenamos los arrays de String con las secciones,
    // filas y ademas especificamos que indice tiene cada elemento segun
    // donde este
    private func beachesToArray(){
        var currentCity: String?
        var rowsInSection: [String]? = []
        var count = 0
        var indexInSection: [Int]? = []
        for beach in self.beaches! {
            if currentCity != nil {
                if beach.city == currentCity! {
                    rowsInSection?.append(beach.name!)
                    indexInSection?.append(count)
                } else {
                    if let index = self.sections?.index(of: beach.city!) {
                        self.rows?[index].append(beach.name!)
                        self.rowsIndex?[index].append(count)
                    } else {
                        self.sections?.append(currentCity!)
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
                rowsInSection?.append(beach.name!)
                indexInSection?.append(count)
            }
            count += 1
        }
        self.sections?.append(currentCity!)
        self.rows?.append(rowsInSection!)
        self.rowsIndex?.append(indexInSection!)
    }
}
