//
//  SelectBeachTableViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 2/1/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import UIKit

class SelectBeachTableViewController: CoreDataTableViewController {
    
    var pZone: Zone?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (pZone?.province)! + " " + (pZone?.pZone)!
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

}
