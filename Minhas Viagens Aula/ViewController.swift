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
    var indiceSelecionado: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //verifica o indice da viagem selecionada
        if let indice = indiceSelecionado {
            
            if indice == -1 { //adcionar
                configuraGerenciadorLocalizacao()
            } else { //listar
                exibirAnotacao( viagem : viagem)
            }
            
        }
        
        //reconhecedor de gestos, no caso de pressionar a tela pelo tempo configurado
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.marcar(gesture:) ))
        reconhecedorGesto.minimumPressDuration = 2
        
        mapa.addGestureRecognizer( reconhecedorGesto )
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //atualiza o mapa com as informacoes do ultimo local selecionado
        let local = locations.last!
        let localizacao = CLLocationCoordinate2D(latitude: local.coordinate.latitude , longitude: local.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let regiao:MKCoordinateRegion = MKCoordinateRegion(center: localizacao, span: span)
        self.mapa.setRegion(regiao, animated: true)
    }
    
    func exibirLocal (latitude: Double, longitude: Double) {
        
        //exibe local ao abrir o mapa
        let localizacao = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let regiao:MKCoordinateRegion = MKCoordinateRegion(center: localizacao, span: span)
        self.mapa.setRegion(regiao, animated: true)
        
    }
    
    func exibirAnotacao (viagem : Dictionary< String, String >) {
        
        //exibe anotação com os dados do endereço
        if let localViagem = viagem["local"] {
            if let latitudeS = viagem["latitude"] {
                if let longitudeS = viagem["longitude"] {
                    if let latitude = Double(latitudeS) {
                        if let longitude = Double(longitudeS) {
                            
                            //adiciona anotacao
                            let anotacao = MKPointAnnotation()
                            anotacao.coordinate.latitude = latitude
                            anotacao.coordinate.longitude = longitude
                            anotacao.title = localViagem
                            self.mapa.addAnnotation(anotacao)
                            
                            exibirLocal(latitude: latitude, longitude: longitude)
                        }
                    }
                }
            }
        }
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
                    self.exibirAnotacao(viagem: self.viagem)
                } else {
                    print(erro as Any)
                }
            })
        }
    }
    //configura a localizacao do usuário
    func configuraGerenciadorLocalizacao () {
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }
 // ---------------------------------------------------------------------------------
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
