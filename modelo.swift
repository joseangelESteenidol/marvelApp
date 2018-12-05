//
//  modelo.swift
//  apis-conex-red
//
//  Created by Dev1 on 30/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import Foundation
import CoreData

struct RootJSON:Codable {
   let etag:String
   struct Data:Codable {
      let count:Int
      struct Results:Codable {
         let id:Int
         let title:String
         let issueNumber:Int
         let variantDescription:String
         let description:String?
         struct Prices:Codable {
            let type:String
            let price:Double
         }
         let prices:[Prices]
         struct Thumbnail:Codable {
            let path:URL
            let imageExtension:String
            enum CodingKeys:String, CodingKey {
               case path
               case imageExtension = "extension"
         }
      }
         let thumbnail:Thumbnail
         struct Creators:Codable {
            struct Items:Codable {
               let name:String
               let role:String?
            }
            let items:[Items]
         }
         let creators:Creators
         let characters:Creators
   }
      let results:[Results]
}
   let data:Data
}

struct datosInternos:Codable {
   let descriptionComic:String?
   let imagenURL:URL
   let issueNumber:Int
   let prices:Double
   let title:String
   let variantDescription:String
   
   init(variantdescription:String, title:String, prices:Double, issuenumber:Int, imagenurl:URL ) {
      let ultimoValor = datosCarga!.data.count
      self.title = title
      self.prices = prices
      self.imagenURL = imagenurl
      self.issueNumber = issuenumber
      self.variantDescription = variantdescription
      self.descriptionComic = ""
   }
   
   
}



var datosCarga:RootJSON?
var etag:String?  //sera necesario meterla en el appdelegate

func cargar(datos:Data) {
   let decode = JSONDecoder()
   do {
      datosCarga = try decode.decode(RootJSON.self, from: datos)
      UserDefaults.standard.set(datosCarga?.etag, forKey: "etag")
      etag = datosCarga?.etag
      NotificationCenter.default.post(name: Notification.Name("OKCARGA"), object: nil)
   } catch {
      print ("FAllo en la serializacion \(error)")
   }
   
   let consultaComics:NSFetchRequest<Comics> = Comics.fetchRequest()
   let numComics = (try? context.count(for: consultaComics)) ?? 0
   if numComics > 0 {
       return
   }

   guard let datos = datosCarga?.data.results else {
      print("error al cargar el fichero de marvel")
      return
   }
   
   let ruta = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
   print(ruta)
   for dato in datos {
      let comic = Comics(context: context)
      comic.title = dato.title
      comic.descriptionComic = dato.description
      if let precio = dato.prices.first?.price  {
         comic.prices = precio
      }  else { print("no hay precio que guardar") }
      comic.variantDescription = dato.variantDescription
      comic.issueNumber = Int32(dato.issueNumber)
      comic.id = Int32(dato.id)
      //creamos la variable final url
      var finalURL = URLComponents (url: dato.thumbnail.path, resolvingAgainstBaseURL: false)
      finalURL!.scheme = "https"
      comic.imagenURL = finalURL!.url!.appendingPathExtension(dato.thumbnail.imageExtension)
      
     /* //vamos a sacar la imagen de la url para introducirla en la base de datos
      let conexion = URLSession.shared
      
      conexion.dataTask(with: comic.imagenURL!) { (data, response, error) in
         guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
            if let error = error {
               print("Error en la conexión de red \(error.localizedDescription)")
            }
            return
         }
         if response.statusCode == 200 {
            comic.imageDisco = data
         }
      }*/
      
      
      //vamos a introducir los personajes
      var auxPersons:[Personajes] = []
      for dato2 in dato.characters.items {
         let consultaPersonajes:NSFetchRequest<Personajes> = Personajes.fetchRequest()
         consultaPersonajes.predicate = NSPredicate (format: "nombre = %@", dato2.name)
         if let puestoQuery = try?  context.fetch(consultaPersonajes), let puesto = puestoQuery.first {
            auxPersons.append(puesto)
         } else {
            let personaje = Personajes(context: context)
            personaje.nombre = dato2.name
            auxPersons.append(personaje)
         }
      }
      comic.personajes = NSOrderedSet(array: auxPersons)
      
      //vamos a introducir los creadores
      var auxCreadores:[Autores] = []
      for dato2 in dato.creators.items {
         let consultaAutores:NSFetchRequest<Autores> = Autores.fetchRequest()
         consultaAutores.predicate = NSPredicate (format: "autor = %@ AND rol = %@", dato2.name, dato2.role!)
         if let puestoQuery = try?  context.fetch(consultaAutores), let puesto = puestoQuery.first {
            auxCreadores.append(puesto)
         } else {
            let autor = Autores(context: context)
            autor.autor = dato2.name
            autor.rol = dato2.role
            auxCreadores.append(autor)
         }
      }
      comic.autores = NSOrderedSet(array: auxCreadores)
      
   }
   saveContext()
}



func cargarDatos() {
   
  
}




var persistentContainer:NSPersistentContainer = {
   let container = NSPersistentContainer (name: "apis_conex_red")
   container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
         fatalError("Error en inicializacion de base de datos")
      }
   }
   return container
}()

var context:NSManagedObjectContext {
   return persistentContainer.viewContext
}

func saveContext() {
   if context.hasChanges {
      do {
         try context.save()
      } catch {
         print("Error en la grabacion de la  base de datos \(error)")
      }
   }
}
