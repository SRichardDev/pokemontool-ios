import Firebase


// Grab susbcribed channels
// Source 1: https://stackoverflow.com/questions/38948720/is-there-anyway-to-access-the-firebase-topics-a-user-is-subscribed-to
// Source 2: https://developers.google.com/instance-id/reference/server#get_information_about_app_instances
extension Messaging {
    
    // Needs to be grabbed from: https://stackoverflow.com/questions/37337512/where-can-i-find-the-api-key-for-firebase-cloud-messaging
    static private let accessToken = "AAAAsHmdISk:APA91bE0Ko9_Tsq3ayNNlCvRfWjU6yBoFIqAQYOUNj-2NMeaBHDHTRwQbc0wij9ki7N6G6xtLnuP6v43RlKcZ874ZYHeeU8qwdDbwvO3EirzEW0jcSb-lfAV7vNtJGyVAdBKz_w9HeYa"
    
    struct Topic: Decodable {
        var name: String?
        var addDate: String?
    }
    
    struct Rel: Decodable {
        var topics = [Topic]()
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let relContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rel)
            let topicsContainer = try relContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .topics )
            
            for key in topicsContainer.allKeys {
                var topic = Topic()
                topic.name = key.stringValue
                
                let topicContainer = try? topicsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: key)
                topic.addDate = try! topicContainer?.decode(String.self, forKey: .addDate)
                
                self.topics.append(topic)
            }
        }
        
        struct CodingKeys: CodingKey {
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            var intValue: Int? { return nil }
            init?(intValue: Int) { return nil }
            
            static let rel = CodingKeys(stringValue: "rel")!
            static let topics = CodingKeys(stringValue: "topics")!
            static let addDate = CodingKeys(stringValue: "addDate")!
        }
    }
    
    func loadTopics(block: @escaping (_ topics: [Messaging.Topic]?, _ error: Error?) -> Void ) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let err = error {
                block(nil, err)
            } else if let result = result {
                let url = URL(string: "https://iid.googleapis.com/iid/info/\(result.token)?details=true")!
                var request = URLRequest(url: url)
                request.addValue("key=\(Messaging.accessToken)", forHTTPHeaderField: "Authorization")
                let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let data = data {
                        let decoder = JSONDecoder()
                        let rel = try? decoder.decode(Rel.self, from: data)
                        block(rel?.topics, error)
                    } else {
                        block(nil, error)
                    }
                }
                dataTask.resume()
            }
        }
    }
}
