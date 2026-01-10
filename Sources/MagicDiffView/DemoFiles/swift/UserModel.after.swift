import Foundation

struct User {
    let id: Int
    let name: String
    let email: String
    let age: Int?
    let avatarURL: URL?
    let createdAt: Date

    init(
        id: Int,
        name: String,
        email: String,
        age: Int? = nil,
        avatarURL: URL? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }

    func validate() -> Bool {
        guard !name.isEmpty else { return false }
        guard !email.isEmpty else { return false }
        guard email.contains("@") && email.contains(".") else { return false }
        guard let age = age else { return true }
        return age >= 13 && age <= 120
    }

    func description() -> String {
        var info = "User(\(id)): \(name) <\(email)>"
        if let age = age {
            info += " [\(age)岁]"
        }
        return info
    }

    var displayName: String {
        name.isEmpty ? "Unknown" : name
    }

    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.uppercased().joined()
    }
}

class UserManager {
    private(set) var users: [User] = []
    private var nextID: Int = 1

    func addUser(_ user: User) -> Bool {
        guard !users.contains(where: { $0.email == user.email }) else {
            return false
        }
        users.append(user)
        return true
    }

    func findUser(id: Int) -> User? {
        return users.first { $0.id == id }
    }

    func findUser(email: String) -> User? {
        return users.first { $0.email == email }
    }

    func removeUser(id: Int) -> Bool {
        let index = users.firstIndex { $0.id == id }
        guard let index = index else { return false }
        users.remove(at: index)
        return true
    }

    func updateUser(id: Int, name: String? = nil, email: String? = nil) -> Bool {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            return false
        }
        if let name = name {
            users[index].name = name
        }
        if let email = email {
            users[index].email = email
        }
        return true
    }

    var sortedUsers: [User] {
        return users.sorted { $0.name < $1.name }
    }

    var adultUsers: [User] {
        return users.filter { $0.age ?? 0 >= 18 }
    }

    func totalCount() -> Int {
        return users.count
    }
}
