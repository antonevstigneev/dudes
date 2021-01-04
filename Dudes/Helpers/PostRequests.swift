//
//  PostRequests.swift
//  Dudes
//
//  Created by Anton Evstigneev on 08.12.2020.
//

import Foundation


// MARK: - Process stickerpack
func postRequest(id: String, emojis: [String], dudes: [String], completion: @escaping (Bool, Error?) -> Void) {
    
    //declare parameter as a dictionary which contains string as key and value combination.
    let parameters: [String: Any] = [
        "id": id,
        "emojis": emojis,
        "dudes": dudes,
    ]
    
    let url = URL(string: "https://dudesstickersbot.herokuapp.com/processStickerpack")!
//    let url = URL(string: "http://192.168.1.47:8080/processStickerpack")!

    //create the session object
    let session = URLSession.shared

    //now create the Request object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
    } catch let error {
        print(error.localizedDescription)
        completion(false, error)
    }

    //HTTP Headers
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request, completionHandler: { data, response, error in

        guard error == nil else {
            completion(false, error)
            return
        }

        completion(true, error)
    })

    task.resume()
}



// MARK: - Receipt verifier
func verifyReceipt(receipt: String, completion: @escaping (Data?, Error?) -> Void) {
    
    //declare parameter as a dictionary which contains string as key and value combination.
    let parameters: [String: Any] = [
        "receipt": receipt,
    ]
    
    let url = URL(string: "https://dudesstickersbot.herokuapp.com/verifyReceipt")!
//    let url = URL(string: "http://192.168.1.47:8080/verifyReceipt")!

    //create the session object
    let session = URLSession.shared

    //now create the Request object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
    } catch let error {
        print(error.localizedDescription)
        completion(nil, error)
    }

    //HTTP Headers
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request, completionHandler: { data, response, error in

        guard error == nil else {
            completion(nil, error)
            return
        }

        completion(data, error)
    })

    task.resume()
}
