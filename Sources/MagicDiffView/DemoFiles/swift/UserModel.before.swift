import Foundation

struct User {
    let id: Int
    let name: String
    let email: String

    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    func validate() -> Bool {
        return !name.isEmpty && !email.isEmpty
    }

    func description() -> String {
        return "User(\(id)): \(name) <\(email)>"
    }
}

class UserManager {
    var users: [User] = []

    func addUser(_ user: User) {
        users.append(user)
    }

    func findUser(id: Int) -> User? {
        return users.first { $0.id == id }
    }

    func removeUser(id: Int) -> Bool {
        let initialCount = users.count
        users.removeAll { $0.id == id }
        return users.count < initialCount
    }
}
