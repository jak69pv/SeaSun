//
//  InitViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 18/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class InitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MODEL
    // Datos XML de la playa
    var beachXML: BeachXMLModel?
    
    // Variable para CoreData
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // Contenido de la linea actual del XMLParser
    var currentContent = String()
    
    // Playa mas cercana
    var nearestBeach: Beach? {
        didSet {
            if nearestBeach == nil {
                // Avisamos de que no se ha podido obtener la playa mas cercana
            }
        }
    }
    
    // Items dentro de la tabla
    var itemsRow: [String] = [
        "North",
        "South",
        "East"
    ]

    // Action de botón de favorito
    @IBAction func goToFavourites(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segues.initToFav, sender: sender)
    }
    
    @IBAction func tapNearestBeach(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Segues.initToDetail, sender: sender)
    }
    
    // Outlet de boton de favoritos
    @IBOutlet weak var favouritesButton: UINavigationItem!
    
    // Barra de busqueda
    @IBOutlet weak var searchBeachBar: UISearchBar!
    
    // Imagen de la playa
    @IBOutlet weak var beachImage: UIImageView!
    
    // Label con temperatura de la playa
    @IBOutlet weak var tempLabel: UILabel!
    
    // Label con nombre playa
    @IBOutlet weak var nameBeachLabel: UILabel!
    
    // Label correspondiente al nombre de la ciudad donde esta la playa
    @IBOutlet weak var cityBeachLabel: UILabel!
    
    // Label con velocidad del viento
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    // Label con la marea
    @IBOutlet weak var swellLabel: UILabel!
    
    // Label con UV
    @IBOutlet weak var UVLabel: UILabel!
    
    // Label con temperatura de agua
    @IBOutlet weak var waterTempLabel: UILabel!
    
    // ImageView con el estado de las playas
    @IBOutlet weak var stateImage: UIImageView!
    
    // Table view de las grandez zonas
    @IBOutlet weak var beachBigZoneTableView: UITableView!
    
    // Vista con los datos de la playa mas cercna
    @IBOutlet weak var showDataCompositionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.showDataCompositionView.sendSubview(toBack: beachImage)
        getAemetXML(beachCode: (nearestBeach?.webCode)!)
        setNearestBeachUIData()
        initTableView()
        initSearchBar()
    }
    
    // Cuando la vista va a desaparecer
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Deseleccionamos la celda que este seleccionada
        if let indexPath = self.beachBigZoneTableView.indexPathForSelectedRow {
            self.beachBigZoneTableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setNearestBeachUIData() {
        self.stateImage.image = getStateImage(withCode: beachXML?.prediction?[0].skyState?[0].f)
        self.beachImage.image = #imageLiteral(resourceName: "val_malvarrosa_intro")
        self.nameBeachLabel?.text = (nearestBeach?.name) ?? "Error"
        self.cityBeachLabel?.text = (nearestBeach?.city) ?? "Error"
        self.tempLabel?.text =  String(describing: (beachXML?.prediction?[0].maxTemp)!)+"º"
        self.windSpeedLabel?.text = "Wind: " +
            getWindString(withCode: beachXML!.prediction?[0].wind?[0].f)
        self.swellLabel?.text = "Swell: " + getSwellString(withCode: beachXML?.prediction?[0].swell?[0].f)
        self.waterTempLabel?.text = "Water temperature: " + (beachXML?.prediction![0].waterTemp!.description)!
        self.UVLabel?.text = "Max UV: " + String(describing: (beachXML?.prediction?[0].maxUV)!)
    }
    
    func getStateImage(withCode: Int?) -> UIImage {
        
        let code = withCode ?? -1
        
        switch code {
        case 100:
            return #imageLiteral(resourceName: "wi_sun")
        case 110:
            return #imageLiteral(resourceName: "wi_partly_cloudy")
        case 120:
            return #imageLiteral(resourceName: "wi_cloudy")
        case 130:
            return #imageLiteral(resourceName: "wi_partly_cloudy_rain")
        case 140:
            return #imageLiteral(resourceName: "wi_rain")
        default:
            return #imageLiteral(resourceName: "error")
        }
        
    }

    private func getAemetXML(beachCode: String) {
        // URL Tipo
        // http://www.aemet.es/xml/playas/play_v2_3003605.xml
        print(AemetURL.url + beachCode + AemetURL.type)
        beachXML = BeachXMLModel(with: beachCode)
        beachXML?.parser()
    }
    
    private func initSearchBar() {
        self.searchBeachBar.placeholder = "Search beach..."
    }
    
    func initTableView() {
        self.beachBigZoneTableView.delegate = self
        self.beachBigZoneTableView.dataSource = self
        self.beachBigZoneTableView.register(UITableViewCell.self, forCellReuseIdentifier: "prototipeCell")
        // Cambiamos color separador de la tabla y hacemos que llegue de lado a lado
        self.beachBigZoneTableView.separatorColor = UIColor.black
        self.beachBigZoneTableView.separatorInset.left = 0
        self.beachBigZoneTableView.separatorInset.right = 0
        self.beachBigZoneTableView.backgroundColor = UIColor.seaSunBlue
        // Mostrar solo las celdas que se ven
        let footerView = UIView()
        self.beachBigZoneTableView.tableFooterView = footerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsRow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.beachBigZoneTableView.dequeueReusableCell(withIdentifier: "prototipeCell")!
                                            as UITableViewCell
        cell.textLabel?.text = self.itemsRow[indexPath.row]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)
        // Indicador del final
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "disclosureBlack"))
        // Color de la celda
        cell.backgroundColor = UIColor.seaSunBlue
        // Estilo de seleccion
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Presentamos el Main.storyboard
        let storyboard = self.storyboard
        let bigZone = self.itemsRow[indexPath.row]
        let zones =  self.getZones(bigZone)
        // Inicializamos el view cotroller de este storyboard y pasamos las variables
        let nextView: SelectProvinceZoneTableViewController = storyboard?.instantiateViewController(withIdentifier: "SelectProvinceTableViewController") as! SelectProvinceZoneTableViewController
        nextView.bigZone = bigZone
        nextView.zones = zones        // Inicializamos el view controller y le pasamos el VC
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    private func getZones(_ bigZone: String) -> ([Zone]?/*, [String]?, [[String]]?*/) {
        var zones: [Zone]?
        //var zonesToArray: ([String]?, [[String]]?)
        managedObjectContext?.performAndWait {
            let fetchRequest = NSFetchRequest<Zone>(entityName: "Zone")
            fetchRequest.predicate = NSPredicate(format: "region == %@", bigZone)
            do {
                zones = try self.managedObjectContext?.fetch(fetchRequest)
                //zonesToArray = self.zonesToArray(inZones: zones)
                print(zones?.count ?? -1)
                
            } catch let error{
                print("Error retrieve beaches: \(error)")
            }
        }
        return zones/*, zonesToArray.0, zonesToArray.1)*/
    }
    


    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.initToFav?:
            break // TODO (or not)
        case Segues.initToDetail?:
            if let ivc = segue.destination as? DetailBeachViewController {
             ivc.beach = nearestBeach
            }
        default:
            break
        }
    }
}
