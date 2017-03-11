//
//  SelectBeachTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 2/1/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import UIKit

class SelectBeachTableViewController: CoreDataTableViewController {
    
    var pZoneTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = pZoneTitle
        prepareTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Buscamos la playa
        let beach = self.fetchedResultsController!.object(at: indexPath) as! Beach
        
        // Creamos la celda
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "beachCell")!
            as UITableViewCell
        
        cell.textLabel?.text = beach.name
        
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
        
        performSegue(withIdentifier: Segues.beachToDetail, sender: indexPath)

    }
    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "beachCell")
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
extension SelectBeachTableViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Segues.beachToDetail?:
            
            if let beachDetailVC = segue.destination as? DetailBeachViewController {
                
                let beach = self.fetchedResultsController!.object(at: sender as! IndexPath) as! Beach
                
                // Inject it into favVC
                beachDetailVC.managedObjectContext = self.fetchedResultsController?.managedObjectContext
                beachDetailVC.beach = beach
                
            }
        default:
            break
        }
    }
    
}
