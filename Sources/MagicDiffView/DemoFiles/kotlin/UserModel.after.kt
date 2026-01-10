import java.time.LocalDateTime
import java.util.regex.Pattern

data class User(
    val id: Int,
    val name: String,
    val email: String,
    val age: Int? = null,
    val avatarUrl: String? = null,
    val createdAt: LocalDateTime = LocalDateTime.now()
) {
    companion object {
        private val EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        )
    }

    fun validate(): Boolean {
        if (name.isBlank()) return false
        if (email.isBlank()) return false
        if (!EMAIL_PATTERN.matcher(email).matches()) return false
        if (age != null && (age < 13 || age > 120)) return false

        return true
    }

    val displayName: String
        get() = name.ifBlank { "Unknown" }

    val initials: String
        get() = name
            .split(" ")
            .filter { it.isNotEmpty() }
            .map { it.first().uppercaseChar() }
            .joinToString("")

    fun toMap(): Map<String, Any?> {
        return mapOf(
            "id" to id,
            "name" to name,
            "email" to email,
            "age" to age,
            "avatarUrl" to avatarUrl,
            "createdAt" to createdAt.toString()
        )
    }

    override fun toString(): String {
        val sb = StringBuilder("User($id): $name <$email>")
        if (age != null) {
            sb.append(" [$age 岁]")
        }
        return sb.toString()
    }
}

class UserManager {
    private val users: MutableList<User> = mutableListOf()
    private var nextId: Int = 1

    fun addUser(user: User): Boolean {
        if (users.any { it.email == user.email }) {
            return false
        }
        users.add(user)
        return true
    }

    fun findUser(id: Int): User? {
        return users.find { it.id == id }
    }

    fun findUserByEmail(email: String): User? {
        return users.find { it.email == email }
    }

    fun removeUser(id: Int): Boolean {
        val index = users.indexOfFirst { it.id == id }
        return if (index >= 0) {
            users.removeAt(index)
            true
        } else {
            false
        }
    }

    fun updateUser(
        id: Int,
        name: String? = null,
        email: String? = null,
        age: Int? = null
    ): Boolean {
        val user = findUser(id) ?: return false

        if (name != null) {
            // For immutable data class, we need to replace the user
            val index = users.indexOf(user)
            users[index] = user.copy(name = name)
        }

        if (email != null) {
            val index = users.indexOf(user)
            users[index] = users[index].copy(email = email)
        }

        if (age != null) {
            val index = users.indexOf(user)
            users[index] = users[index].copy(age = age)
        }

        return true
    }

    val sortedUsers: List<User>
        get() = users.sortedBy { it.name }

    val adultUsers: List<User>
        get() = users.filter { it.age != null && it.age!! >= 18 }

    fun getUsersByAgeRange(minAge: Int, maxAge: Int): List<User> {
        return users.filter {
            it.age != null && it.age in minAge..maxAge
        }
    }

    fun totalCount(): Int = users.size

    fun createUser(
        name: String,
        email: String,
        age: Int? = null
    ): User {
        val user = User(
            id = nextId,
            name = name,
            email = email,
            age = age
        )
        addUser(user)
        nextId++
        return user
    }
}
