data class User(
    val id: Int,
    val name: String,
    val email: String
) {
    fun validate(): Boolean {
        return name.isNotEmpty() && email.isNotEmpty()
    }

    override fun toString(): String {
        return "User($id): $name <$email>"
    }
}

class UserManager {
    private val users: MutableList<User> = mutableListOf()

    fun addUser(user: User) {
        users.add(user)
    }

    fun findUser(id: Int): User? {
        return users.find { it.id == id }
    }

    fun removeUser(id: Int): Boolean {
        val initialSize = users.size
        users.removeAll { it.id == id }
        return users.size < initialSize
    }

    fun totalCount(): Int {
        return users.size
    }
}
