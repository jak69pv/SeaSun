//
//  SelectProvinceTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class SelectProvinceZoneTableViewController: CoreDataTableViewController {
    
    var bigZone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bigZone
        prepareTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Buscamos la zona
        let zone = self.fetchedResultsController!.object(at: indexPath) as! Zone
        
        // Creamos la celda
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "zoneCell")!
            as UITableViewCell
            
            as UITableViewCell
        cell.textLabel?.text = zone.pZone
        
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
        
        let pZone = self.fetchedResultsController!.object(at: indexPath) as! Zone
        
        // Presentamos el Main.storyboard
        let storyboard = self.storyboard
        
        // Inicializamos el view cotroller de este storyboard y pasamos las variables
        let nextView: SelectBeachTableViewController = storyboard?.instantiateViewController(withIdentifier: "SelectBeachTableViewController") as! SelectBeachTableViewController
        nextView.pZone = pZone
        nextView.beaches = pZone.beaches?.allObjects as! [Beach]?
        
        // Inicializamos el view controller y le pasamos el VC
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "zoneCell")
        // Cambiamos color separador de la tabla y hacemos que llegue de lado a lado
        self.tableView.separatorColor = UIColor.black
        self.tableView.separatorInset.left = 0
        self.tableView.separatorInset.right = 0
        self.tableView.backgroundColor = UIColor.seaSunBlue
        // Mostrar solo las celdas que se ven
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
        
    }
}
