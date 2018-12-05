//
//  tools.swift
//  apis-conex-red
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit
import CoreData

func recuperaURL(url:URL, callback:@escaping (UIImage) -> Void) {
   let conexion = URLSession.shared
   conexion.dataTask(with: url) { (data, response, error) in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("Error en la conexión de red \(error.localizedDescription)")
         }
         return
      }
      if response.statusCode == 200 {
         if let imagen = UIImage(data: data) {
            callback(imagen)
         }
      }
      }.resume()
}

let publicKey = "d02b974a04688071b5d613a652c9565e"
let privateKey = "3709cb5a2b3aecb7e2552b02595dda2f30f17c44"

var baseURL = URL(string: "https://gateway.marvel.com/v1/public")!

func conexionMarvel() {
  
   let ts = "\(Date().timeIntervalSince1970)"
   let valorFirma = ts+privateKey+publicKey
   let queryts = URLQueryItem (name: "ts", value: ts)
   let queryapikey = URLQueryItem (name: "apikey", value: publicKey)
   let queryHash = URLQueryItem (name: "hash", value: valorFirma.MD5)
   let queryFormat = URLQueryItem (name: "format", value: "hardcover")
   let queryLimit = URLQueryItem (name: "limit", value: "100")
   let queryOrder = URLQueryItem (name: "orderBy", value: "onsaleDate")
   
   var url = URLComponents()
   url.scheme = baseURL.scheme
   url.host = baseURL.host
   url.path = baseURL.path
   url.queryItems = [queryts,queryapikey,queryHash,queryFormat,queryOrder,queryLimit]
   
   let session = URLSession.shared
   var request = URLRequest(url: url.url!.appendingPathComponent("comics"))
   request.httpMethod = "GET"
   request.addValue("*/*", forHTTPHeaderField: "Accept")
   /*if let etag = etag {
      request.addValue(etag, forHTTPHeaderField: "If-None-Match")
   }*/
   session.dataTask(with: request) { (data,response,error) in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print ("Error en la comunicacion \(error)")
         }
         return
      }
      if response.statusCode == 200 {
         cargar(datos: data)
   } else {
      print("Error en la respuesta de conexion \(response.statusCode)")
      }
   
}.resume()



   
func getDateTime() -> String {
   let fecha = Date()
   let formateador = DateFormatter()
   formateador.dateFormat = "ddMMyyyyhhmmss"
   return formateador.string(from: fecha)
   
}
}

extension String {
   var MD5:String? {
      guard  let messageData = self.data(using: .utf8) else {
         return nil
      }
      var datoMD5 = Data(count: Int(CC_MD5_DIGEST_LENGTH))
      _ = datoMD5.withUnsafeMutableBytes {
         bytes in
         messageData.withUnsafeBytes  {
            messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), bytes)         }
      }
      var MD5String = String()
      for c in datoMD5  {
         MD5String += String(format: "%02x", c)
      }
      return MD5String
      }
   
}


