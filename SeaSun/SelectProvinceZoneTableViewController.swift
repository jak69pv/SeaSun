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
        
        performSegue(withIdentifier: Segues.provinceToBeach, sender: indexPath)
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

// MARK - Navigation
extension SelectProvinceZoneTableViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Segues.provinceToBeach?:
            
            if let provinceVC = segue.destination as? SelectBeachTableViewController {
                
                let pZone = self.fetchedResultsController!.object(at: sender as! IndexPath) as! Zone
            
                // Creamos la fetch request
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Beach")
                fr.sortDescriptors = [NSSortDescriptor(key: "city", ascending: true)]
                
                fr.predicate = NSPredicate(format: "zoneCode == %@", argumentArray: [pZone.code!])
                
                // Create FetchedResultController
                let fc = NSFetchedResultsController(
                    fetchRequest: fr,
                    managedObjectContext: self.fetchedResultsController!.managedObjectContext,
                    sectionNameKeyPath: "city",
                    cacheName: nil)
                
                // Inject it into favVC
                provinceVC.fetchedResultsController = fc
                provinceVC.pZoneTitle = (pZone.province)! + " " + (pZone.pZone)!
                
            }
        default:
            break
        }
    }
    
}
