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
    
    // Datos de la BBDD de la playa
    var prediction: [Weather]?
    
    // Contenido de la linea actual del XMLParser
    var currentContent = String()
    
    // CoreDataStack 
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
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
    
    @IBOutlet weak var nearestBeachLabel: UILabel!
    
    // Outlet de boton de favoritos
    @IBOutlet weak var favouritesButton: UINavigationItem!
    @IBOutlet weak var favButton: UIBarButtonItem!
    
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
        nearestBeachLabel.text = labelsText.nearestBeach
        favouritesButton.title = labelsText.appName
        favButton.title = labelsText.favourites
        initTableView()
        initSearchBar()
        // Do any additional setup after loading the view.
        self.showDataCompositionView.sendSubview(toBack: beachImage)
        prediction = Weather.getPrediction(context: stack.context, beach: nearestBeach!)
        if (prediction == nil || prediction!.count == 1) && isInternetAvailable(){
            DispatchQueue.global(qos: .background).async {
                self.getAemetXML(beachCode: (self.nearestBeach?.webCode)!)
                DispatchQueue.main.sync {
                    self.prediction = Weather.addWeatherPrediction(context: self.stack.context, beach: self.nearestBeach!, beachData: self.beachXML!)
                    self.setNearestBeachUIData()
                }
            }
        } else { setNearestBeachUIData() }
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
        if prediction != nil  {
            self.tempLabel?.text =  String(describing: prediction![0].maxTemp)+"º"
            self.waterTempLabel?.text = labelsText.waterTempTitle + ": " + prediction![0].waterTemp.description
            self.UVLabel?.text = labelsText.uvTitle + ": " + String(describing: prediction![0].maxUV)
            self.stateImage.image = getStateImage(withCode: Int(prediction![0].skyState1))
            self.swellLabel?.text = labelsText.swellTitle + ": " + getSwellString(withCode: Int(prediction![0].swell1))
            self.windSpeedLabel?.text = labelsText.windTitle + ": " +
             getWindString(withCode: Int(prediction![0].wind1))
        } else {
            self.tempLabel?.text =  "--º"
            self.waterTempLabel?.text = labelsText.waterTempTitle + ": " + labelsText.error
            self.UVLabel?.text = labelsText.uvTitle + ": " + labelsText.error
            self.stateImage.image = #imageLiteral(resourceName: "error")
            self.swellLabel?.text = labelsText.swellTitle + ": " + labelsText.error
            self.windSpeedLabel?.text = labelsText.windTitle + ": " + labelsText.error
        }
        self.beachImage.image = #imageLiteral(resourceName: "val_malvarrosa_intro")
        self.nameBeachLabel?.text = (nearestBeach?.name) ?? labelsText.error
        self.cityBeachLabel?.text = (nearestBeach?.city) ?? labelsText.error

    }

    private func getAemetXML(beachCode: String) {
        // URL Tipo
        // http://www.aemet.es/xml/playas/play_v2_3003605.xml
        print(AemetURL.url + beachCode + AemetURL.type)
        beachXML = BeachXMLModel(with: beachCode)
        beachXML?.parser()
    }
    
    private func initSearchBar() {
        self.searchBeachBar.placeholder = labelsText.searchBeachPlaceholder + "..."
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
        //let footerView = UIView()
        //self.beachBigZoneTableView.tableFooterView = UIView.init(frame: CGRect.zero)
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
        cell.backgroundColor = UIColor.seaSunOrange
        // Estilo de seleccion
        cell.selectionStyle = UITableViewCellSelectionStyle.blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Segues.initToRegion, sender: itemsRow[indexPath.row])

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.beachBigZoneTableView.frame.size.height / 3
    }
    
    private func getZones(_ bigZone: String) -> ([Zone]?/*, [String]?, [[String]]?*/) {
        var zones: [Zone]?
        //var zonesToArray: ([String]?, [[String]]?)
        stack.context.performAndWait {
            let fetchRequest = NSFetchRequest<Zone>(entityName: "Zone")
            fetchRequest.predicate = NSPredicate(format: "region == %@", bigZone)
            do {
                zones = try self.stack.context.fetch(fetchRequest)
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
            
            if let favVC = segue.destination as? FavouriteBeachesTableViewController {

                // Creamos la fetch request
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Beach")
                fr.sortDescriptors = [NSSortDescriptor(key: "city", ascending: true)]
                
                fr.predicate = NSPredicate(format: "fav == %@", argumentArray: [true])
                
                // Create FetchedResultController
                let fc = NSFetchedResultsController(
                    fetchRequest: fr,
                    managedObjectContext: self.stack.context,
                    sectionNameKeyPath: "city",
                    cacheName: nil)
                
                // Inject it into favVC
                favVC.fetchedResultsController = fc
                
            }
            
        case Segues.initToDetail?:
            if let ivc = segue.destination as? DetailBeachViewController {
                ivc.beach = nearestBeach
                ivc.beachXML = self.beachXML
                ivc.managedObjectContext = self.stack.context
            }
            
        case Segues.initToRegion?:
            
            if let regionVC = segue.destination as? SelectProvinceZoneTableViewController {
                
                // Creamos la fetch request
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Zone")
                fr.sortDescriptors = [NSSortDescriptor(key: "province", ascending: true)]
                
                fr.predicate = NSPredicate(format: "region == %@", argumentArray: [sender as! String])
                
                // Create FetchedResultController
                let fc = NSFetchedResultsController(
                    fetchRequest: fr,
                    managedObjectContext: self.stack.context,
                    sectionNameKeyPath: "province",
                    cacheName: nil)
                
                // Inject it into favVC
                regionVC.fetchedResultsController = fc
                regionVC.bigZone = sender as? String
                regionVC.title = sender as? String
                
            }
        default:
            break
        }
    }
}


