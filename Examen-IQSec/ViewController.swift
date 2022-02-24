//
//  ViewController.swift
//  Examen-IQSec
//
//  Created by Juan Michelena on 23/02/22.
//

import UIKit
import MapKit
import Photos


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    // Colores principales
    
    let mainColor = UIColor(red: 45.0/255.0, green: 43.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    
    let secondaryColor = UIColor(red: 0.0/255.0, green: 125.0/255.0, blue: 188.0/255.0, alpha: 1.0)
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var photoMainContainerView: UIView!
    @IBOutlet weak var takePhotoButtonOutlet: UIButton!
    @IBAction func takePhotoButton(_ sender: Any) {
        
        // Invocación del ImagePickerVC
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .camera
        
        requestPhotoAuthorization()
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deniedView: UIView!
    
    // Localización
    
    let locationManager = CLLocationManager()
    
    // Fotografía
    
    let photoImage = UIImageView()
    
    var imagePickerVC = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // No mostrar la vista de denegado en el mapa por default
        
        deniedView.isHidden = true
        
        // Función de diseño de la vista superior
        
        topViewDesign(view: topView)
        
        // Función de agregado de imagen al contenedor
        
        addImageView(view: photoMainContainerView)
        
        
        // Función de diseño de botón
        
        buttonDesign(btn: takePhotoButtonOutlet)
        
        // Habilitar Permisos de Localización
        
        CLLocationManager.authorizationStatus()
        
        if CLLocationManager.authorizationStatus() == .denied {
            deniedView.isHidden = false
            deniedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        } else {
            deniedView.isHidden = true
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // Revisión de permisos
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(statusManager),
            name: .flagsChanged,
            object: nil)
        updateUserInterface()
    }
    
    func updateUserInterface() {
            switch Network.reachability.status {
            case .unreachable:
                let connectionAlert = UIAlertController(title: "Problemas de Conexión", message: "Por favor revise su conexión e intente ingresar de nuevo.", preferredStyle: .alert)
                present(connectionAlert, animated: true)
            case .wwan:
                print("WWAN CONNECTION")
            case .wifi:
                print("WIFI CONNECTION")
            }
            print("Reachability Summary")
            print("Status:", Network.reachability.status)
            print("HostName:", Network.reachability.hostname ?? "nil")
            print("Reachable:", Network.reachability.isReachable)
            print("Wifi:", Network.reachability.isReachableViaWiFi)
        }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    // Función de ImagePicker

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePickerVC.dismiss(animated: true, completion: nil)
        
        photoImage.image = info[.originalImage] as? UIImage
    }
    
    // Agregado de sombra y borde a la TopView
    
    func topViewDesign(view: UIView){
        
        let viewLayer = view.layer
        viewLayer.masksToBounds = false
        viewLayer.shadowColor = UIColor.lightGray.cgColor
        viewLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewLayer.shadowOpacity = 1.0
        viewLayer.shadowRadius = 0
        viewLayer.cornerRadius = 5.0
        
    }
    
    // Función general de agregado de ImageView
    
    func addImageView(view: UIView){
        
        view.backgroundColor = .white
        
        // Cambio de color de borde y agregado de elevación
        let viewLayer = view.layer
        viewLayer.cornerRadius = 5.0
        viewLayer.borderColor = mainColor.cgColor
        viewLayer.borderWidth = 5.0
        
        // Agregado de ImageView y Constraints al MainContainer
        
        photoImage.image = UIImage(named: "user_placeholder")
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImage)
        
        NSLayoutConstraint.activate([
            photoImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            photoImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            photoImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            photoImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    // Revisar configuración de permisos de cámara y librería de fotos.
    
    func requestPhotoAuthorization(){
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            self.present(self.imagePickerVC, animated: true)
        case .denied:
            self.showDeniedPhotoAlert()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    self?.present(self!.imagePickerVC, animated: true)
                default:
                    self?.showDeniedPhotoAlert()
                }
            }
        default:
            print("No se encontró estado de autorización")
        }
    }
    
    // Mostrar alerta en el caso de que el usuario haya denegado el acceso a las fotos o librería
    
    func showDeniedPhotoAlert(){
        let photoAlert = UIAlertController(title: "Permiso Denegado", message: "Por favor dirijase a Configuración en su dispositivo y habilite los permisos de cámara para tomar una captura.", preferredStyle: .alert)
        photoAlert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(photoAlert, animated: true)
    }
    
    // Diseño de botón de toma de foto
    
    func buttonDesign(btn: UIButton) {
        
        btn.backgroundColor = secondaryColor
        
        let btnLayer = btn.layer
        btnLayer.cornerRadius = 5.0
        btnLayer.shadowColor = UIColor.darkGray.cgColor
        btnLayer.shadowOpacity = 0.5
        btnLayer.shadowRadius = 1.0
        btnLayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        
    }
    
    // Obtención de Ubicación (latitud y longitud)
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let centerLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let spanLocation = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        
        let region = MKCoordinateRegion(center: centerLocation, span: spanLocation)
        
        mapView.setRegion(region, animated: true)
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = location.coordinate
        mapView.addAnnotation(mapAnnotation)
        
    }
    
    // Mostrar alerta en el caso de que el usuario haya denegado el acceso a la ubicación
    
    func showDeniedLocationAlert(){
        let photoAlert = UIAlertController(title: "Permiso Denegado", message: "Por favor dirijase a Configuración en su dispositivo y habilite los permisos de localización para mostrar su ubicación.", preferredStyle: .alert)
        photoAlert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(photoAlert, animated: true)
    }
}

