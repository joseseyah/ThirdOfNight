import Foundation
import FirebaseFirestore

// Function to fetch mosques from Firebase Firestore
func fetchMosqueList(completion: @escaping ([String]) -> Void) {
    let db = Firestore.firestore()
    var mosqueList = [String]()
    
    // Fetch documents from the "Mosques" collection
    db.collection("Mosques").getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error fetching mosques: \(error.localizedDescription)")
            completion([]) // Return an empty list in case of error
            return
        }
        
        guard let documents = querySnapshot?.documents else {
            completion([]) // Return an empty list if no documents
            return
        }
        
        // Extract mosque names and add to the list
        mosqueList = documents.compactMap { $0.documentID }
        
        // Pass the fetched list to the completion handler
        completion(mosqueList)
    }
}
