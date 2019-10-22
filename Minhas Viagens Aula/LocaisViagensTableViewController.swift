//
//  LocaisViagensTableViewController.swift
//  Minhas Viagens Aula
//
//  Created by Matheus Rodrigues Araujo on 21/10/19.
//  Copyright © 2019 Curso IOS. All rights reserved.
//

import UIKit

class LocaisViagensTableViewController: UITableViewController {
    
    var locaisViagens: [ Dictionary< String, String > ] = []
    var controleNavegacao = "adicionar"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        controleNavegacao = "adicionar"
        atualizarViagens()
    }
    
    // atualiza a tela com a viagens adicionadas
    func atualizarViagens() {
        locaisViagens = ArmazenamentoDados().listarViagens()
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locaisViagens.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        celula.textLabel?.text = locaisViagens[ indexPath.row ]["local"]

        return celula
    }
// ----------------------------------------------------------------------------------------
    //Exclui celula selecionada e atualiza a pagina
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            ArmazenamentoDados().removerViagem( indice: indexPath.row )
            atualizarViagens()
        }
    }
    //ao clicar na viagem direciona para aquela viage no mapa
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //executa uma segue a partir de seu identificador
        self.controleNavegacao = "listar"
        performSegue(withIdentifier: "verLocal", sender: indexPath.row )
    }

//----------------------------------------------------------------------------------------------------
    
    //configura a tela de destino ao mudar de tela
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "verLocal" {
            
            let viewControllerDestino = segue.destination as! ViewController
            if self.controleNavegacao == "listar" {
                if let indiceRecuperado = sender {
                    
                    let indice = indiceRecuperado as! Int
                    viewControllerDestino.viagem = locaisViagens[ indice ]
                    viewControllerDestino.indiceSelecionado = indice
                }
            } else {
                viewControllerDestino.viagem = [:]
                viewControllerDestino.indiceSelecionado = -1
            }
        }
    }


}
