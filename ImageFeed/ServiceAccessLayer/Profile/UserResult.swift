import Foundation

struct UserResult: Codable {
    let profileImage: [String: String]
    
    func getSmallProfileImageURL() -> URL? {
        guard let urlString = profileImage["small"] else { return nil }
        return URL(string: urlString)
    }
}
