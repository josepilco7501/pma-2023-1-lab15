//
//  ViewController.swift
//  PokemonGo
//
//  Created by Jose Pilco on 28/06/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var ubicacion = CLLocationManager()
    var contActualizaciones = 0
    var pokemons:[Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemon()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            setup()
        }else{
            ubicacion.requestWhenInUseAuthorization()
        }
    }
    
    func setup(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        ubicacion.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true)  {(Timer) in
            if let coord = self.ubicacion.location?.coordinate{
                //let pin = MKPointAnnotation()
                //pin.coordinate = coord
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                let pin = PokePin(coord: coord, pokemon: pokemon)
                let randomLat = (Double(arc4random_uniform(200))-100.0)/5000.0
                let randomLon = (Double(arc4random_uniform(200))-100.0)/5000.0
                pin.coordinate.latitude += randomLat
                pin.coordinate.longitude += randomLon
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            setup()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones < 1 {
            let region = MKCoordinateRegion.init(center:ubicacion.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }else{
            ubicacion.stopUpdatingLocation()
        }
        
        //print("Ubiacion atualizada")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pinview.image = UIImage(named: "player")
            var frame = pinview.frame
            frame.size.height = 50
            frame.size.width = 50
            pinview.frame = frame
            return pinview
        }
        
        let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //pinview.image = UIImage(named: "mew")
        let pokemon = (annotation as! PokePin).pokemon
        pinview.image = UIImage(named: pokemon.imagenNombre!)
        var frame = pinview.frame
        frame.size.height = 50
        frame.size.width = 50
        pinview.frame = frame
        return pinview
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation{
            return
        }
        
        let region = MKCoordinateRegion.init(center:
            (view.annotation?.coordinate)!, latitudinalMeters: 1000,longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ (Timer) in
            if let coord = self.ubicacion.location?.coordinate{
                let pokemon = (view.annotation as! PokePin).pokemon
                if mapView.visibleMapRect.contains(MKMapPoint(coord)){
                    print("Puede atrapar el pokemon")
                    pokemon.atrapado = true
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    mapView.removeAnnotation(view.annotation!)
                    //Mensaje al atarpar unn pokmon
                    let alertaVC = UIAlertController(title: "Felicidades!!", message:"Atrapaste el pokemon \(pokemon.nombre!)", preferredStyle: .alert)
                    let pokedexAction = UIAlertAction(title: "Ver Pokedex", style: .default, handler: {( action ) in
                        self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                    })
                    alertaVC.addAction(pokedexAction)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertaVC.addAction(okAction)
                    self.present(alertaVC, animated: true, completion: nil)
                }else{
                    print("No se puede atrapar el pokemon")
                    let alertaVC = UIAlertController(title: "Upss. Esta muy lejos", message:"No se puede atrapar el pokemon\(pokemon.nombre!)). Acerquese mas", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertaVC.addAction(okAction)
                    self.present(alertaVC, animated: true, completion: nil)
                     
                }
            }
        }
    }
    
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion.init(center:
                coord,latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true )
            contActualizaciones += 1
        }
    }
    

    

}

