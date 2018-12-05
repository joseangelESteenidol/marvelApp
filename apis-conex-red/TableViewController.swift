//
//  TableViewController.swift
//  apis-conex-red
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
   
   lazy var resultComics:NSFetchedResultsController<Comics> = {
      let fetchComics:NSFetchRequest<Comics> = Comics.fetchRequest() //select * from personas
      if let predicado = predicate {          //posible futuro predicado,where pero que de momento esta vacio
         fetchComics.predicate = predicado
      }
      var orden = [NSSortDescriptor(key: #keyPath(Comics.id), ascending: false)] //sort del select
      orden.append(contentsOf: sortedResult)
      fetchComics.sortDescriptors = sortedResult
      return NSFetchedResultsController(fetchRequest: fetchComics, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
   }()
   
   lazy var refresh: UIRefreshControl = {
      let refresh = UIRefreshControl()
      refresh.addTarget(self, action:  #selector(self.refrescarDatos), for: UIControl.Event.valueChanged)
      refresh.tintColor = .red
      return refresh
   }()
   
   var refresco = false
   
   var predicate:NSPredicate?
   var sortedResult:[NSSortDescriptor] = []
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
         conexionMarvel()
         refreshControl = refresh
         NotificationCenter.default.addObserver(forName: NSNotification.Name("OKCARGA"), object: nil, queue: OperationQueue.main) {
         _ in
         self.recargaDatos()
         if self.refresco {
               self.refresco = false
               self.refresh.endRefreshing()
            }
           
      }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
   
   @objc func refrescarDatos() {
      self.refresco = true
      conexionMarvel()
   }
   
   func recargaDatos() {
      do {
         try resultComics.performFetch()
      } catch {
         print("Error en la consulta \(error)")
      }
      tableView.reloadData()
   }
   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return resultComics.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultComics.sections?.first?.numberOfObjects ?? 0
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Zelda", for: indexPath) as! TableViewCell
      
         let datosComic = resultComics.object(at: indexPath)
         cell.titulo.text =  datosComic.title
         var descripcionFinal:String = ""
         if let descripcion = datosComic.descriptionComic {
            descripcionFinal += descripcion
         }

     
             descripcionFinal += "\n"
             descripcionFinal += "PRECIO: \(datosComic.prices)"
     
        
      cell.caption.text = descripcionFinal
      if let url = datosComic.imagenURL {
      recuperaURL(url: url) { imagen in
               DispatchQueue.main.async {
                  if tableView.visibleCells.contains(cell) {
                     cell.imagen.image = imagen
                  }
                  datosComic.imageDisco = imagen.pngData()
                  saveContext()
            }
         }
      }
   

        // Configure the cell...

        return cell
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   deinit {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name("OKCARGA"), object: nil)
   }
}
