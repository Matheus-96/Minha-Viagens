//
//  ViewController.swift
//  Minhas Viagens Aula
//
//  Created by Matheus Rodrigues Araujo on 21/10/19.
//  Copyright © 2019 Curso IOS. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    var viagem: Dictionary< String, String > = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuraGerenciadorLocalizacao()
        
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.marcar(gesture:) ))
        reconhecedorGesto.minimumPressDuration = 2
        
        mapa.addGestureRecognizer( reconhecedorGesto )
    }
    //método q será executado quando o usuário segurar a tela
    @objc func marcar( gesture: UIGestureRecognizer ) {
        
        if gesture.state == UIGestureRecognizer.State.began {
           
            //recupera as coordenadas do ponto selecionado
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert(pontoSelecionado, toCoordinateFrom: self.mapa)
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            //recupera o endereco do ponto selecionado
            var localCompleto = ""
            CLGeocoder().reverseGeocodeLocation(localizacao, completionHandler: { (local, erro) in
                if erro == nil {
                    if let dadosLocal = local?.first {
                        if let nome = dadosLocal.name {
                            localCompleto = nome
                        } else{
                            if let endereco = dadosLocal.thoroughfare {
                                localCompleto = endereco
                            }
                        }
                    }
                    //Salvar dados no dispositivo
                    self.viagem = ["local": localCompleto, "latitude":String( coordenadas.latitude ), "longitude":String( coordenadas.longitude )]
                    ArmazenamentoDados().salvarViagem(viagem: self.viagem)
                    print( ArmazenamentoDados().listarViagens() )
                    
                    //exibe anotação com os dados do endereço
                    let anotacao = MKPointAnnotation()
                    anotacao.coordinate.latitude = coordenadas.latitude
                    anotacao.coordinate.longitude = coordenadas.longitude
                    anotacao.title = localCompleto
                    self.mapa.addAnnotation(anotacao)
                } else {
                    print(erro as Any)
                }
            })
        }
    }
    
    func configuraGerenciadorLocalizacao () {
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }
    
    // abre a janela de configuracao do dispositivo para que o usuario habilite a permissao necessária
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse {
            
            let alertaController = UIAlertController(title: "Permissão de localização", message: "Necessário permissão para acesso à sua localização! Por favor, habilite!", preferredStyle: .alert)
            let acaoConfiguracoes = UIAlertAction(title: "Abrir Configurações", style: .default, handler: {
                (alertaConfiguracoes) in
                
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString ) {
                    UIApplication.shared.open(configuracoes as URL)
                }
            })
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil )
            
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present( alertaController, animated: true, completion: nil)
        }
    }
}
