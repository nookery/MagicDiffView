import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class User {
    private int id;
    private String name;
    private String email;

    public User(int id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean validate() {
        return name != null && !name.isEmpty()
                && email != null && !email.isEmpty();
    }

    @Override
    public String toString() {
        return "User(" + id + "): " + name + " <" + email + ">";
    }
}

class UserManager {
    private List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
    }

    public Optional<User> findUser(int id) {
        return users.stream()
                .filter(u -> u.getId() == id)
                .findFirst();
    }

    public boolean removeUser(int id) {
        int initialSize = users.size();
        users.removeIf(u -> u.getId() == id);
        return users.size() < initialSize;
    }

    public int totalCount() {
        return users.size();
    }
}
