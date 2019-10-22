//
//  ArmazenamentoDados.swift
//  Minhas Viagens Aula
//
//  Created by Matheus Rodrigues Araujo on 22/10/19.
//  Copyright © 2019 Curso IOS. All rights reserved.
//

import UIKit

class ArmazenamentoDados {
    
    let chaveArmazenamento = "locaisViagem"
    var viagens: [ Dictionary< String, String> ] = []
    
    func getDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func salvarViagem(viagem: Dictionary< String, String> ) {
        
        viagens = listarViagens()
        viagens.append(viagem)
        getDefaults().set(viagens, forKey: chaveArmazenamento)
        getDefaults().synchronize()
    }
    
    func listarViagens() -> [ Dictionary< String, String> ] {
        
        //usar esse remove quando estiver dando erro ao converter o array de dados
        //getDefaults().removeObject(forKey: chaveArmazenamento)
        
        let dados = getDefaults().object(forKey: chaveArmazenamento)
        if dados != nil {
            print(dados)
            return dados as! Array
        }else{
            return []
        }
    }
    
    func removerViagem(){
        
    }
    
}
