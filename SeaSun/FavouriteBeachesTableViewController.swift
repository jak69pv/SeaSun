//
//  FavouriteBeachesTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class FavouriteBeachesTableViewController: CoreDataTableViewController {
    
    // Titulo de la vista
    let favTableViewTitle = "Favourite Beaches"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        self.navigationItem.title = self.favTableViewTitle
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Buscamos la playa
        let beach = self.fetchedResultsController!.object(at: indexPath) as! Beach
        
        // Creamos la celda
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "favCell")!
            as UITableViewCell
       
        // La rellenamos
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
        
        // Buscamos la playa
        let beach = self.fetchedResultsController!.object(at: indexPath) as! Beach
        
        // Presentamos el Main.storyboard
        let storyboard = self.storyboard
        
        // Inicializamos el view cotroller de este storyboard y pasamos las variables
        let nextView: DetailBeachViewController = storyboard?.instantiateViewController(withIdentifier: "DetailBeachViewController") as! DetailBeachViewController
        nextView.beach = beach
        
        // Inicializamos el view controller y le pasamos el VC
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    

    
    private func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "favCell")
        // Cambiamos color separador de la tabla y hacemos que llegue de lado a lado
        self.tableView.separatorColor = UIColor.black
        self.tableView.separatorInset.left = 0
        self.tableView.separatorInset.right = 0
        self.tableView.backgroundColor = UIColor.seaSunBlue
        // Mostrar solo las celdas que se ven
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
    }
    
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.favToDetail?:
            break
        default:
            break
        }
    }
}

//MARK - Delete a fav beach
extension FavouriteBeachesTableViewController{
    
    // Indica que se pueden editar las filas
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // removeAndReloadTableViewData(at: indexPath)
            
            // Hacemos la alerta
            let alert = UIAlertController(title: labelsText.alertTitle, message: labelsText.alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: labelsText.alertCancel, style: .cancel, handler: { action in
                return
            }))
            
            alert.addAction(UIAlertAction(title: labelsText.alertOk ,style: .default, handler: { action in
                self.removeAndReloadTableViewData(at: indexPath)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    private func removeAndReloadTableViewData(at indexPath: IndexPath) {
        
        // Buscamos la playa
        let beach = self.fetchedResultsController!.object(at: indexPath) as! Beach
        
        // La quitamos de favoritos
        beach.fav = false
        
    }
    
}
