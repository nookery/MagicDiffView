import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class User {
    private int id;
    private String name;
    private String email;
    private Integer age;
    private String avatarUrl;
    private LocalDateTime createdAt;

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    public User(int id, String name, String email) {
        this(id, name, email, null, null, LocalDateTime.now());
    }

    public User(int id, String name, String email, Integer age, String avatarUrl, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.age = age;
        this.avatarUrl = avatarUrl;
        this.createdAt = createdAt;
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

    public Optional<Integer> getAge() {
        return Optional.ofNullable(age);
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public Optional<String> getAvatarUrl() {
        return Optional.ofNullable(avatarUrl);
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public boolean validate() {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }

        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            return false;
        }

        if (age != null && (age < 13 || age > 120)) {
            return false;
        }

        return true;
    }

    public String getDisplayName() {
        return (name != null && !name.isEmpty()) ? name : "Unknown";
    }

    public String getInitials() {
        if (name == null || name.isEmpty()) {
            return "";
        }

        StringBuilder initials = new StringBuilder();
        for (String part : name.split("\\s+")) {
            if (!part.isEmpty()) {
                initials.append(Character.toUpperCase(part.charAt(0)));
            }
        }

        return initials.toString();
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("User(").append(id).append("): ")
          .append(name).append(" <").append(email).append(">");

        if (age != null) {
            sb.append(" [").append(age).append("岁]");
        }

        return sb.toString();
    }
}

class UserManager {
    private final List<User> users = new ArrayList<>();
    private int nextId = 1;

    public boolean addUser(User user) {
        if (users.stream().anyMatch(u -> u.getEmail().equals(user.getEmail()))) {
            return false;
        }
        users.add(user);
        return true;
    }

    public Optional<User> findUser(int id) {
        return users.stream()
                .filter(u -> u.getId() == id)
                .findFirst();
    }

    public Optional<User> findUserByEmail(String email) {
        return users.stream()
                .filter(u -> u.getEmail().equals(email))
                .findFirst();
    }

    public boolean removeUser(int id) {
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getId() == id) {
                users.remove(i);
                return true;
            }
        }
        return false;
    }

    public boolean updateUser(int id, String name, String email, Integer age) {
        Optional<User> userOpt = findUser(id);
        if (userOpt.isEmpty()) {
            return false;
        }

        User user = userOpt.get();
        if (name != null) {
            user.setName(name);
        }
        if (email != null) {
            user.setEmail(email);
        }
        if (age != null) {
            user.setAge(age);
        }

        return true;
    }

    public List<User> getSortedUsers() {
        return users.stream()
                .sorted((u1, u2) -> u1.getName().compareTo(u2.getName()))
                .collect(Collectors.toList());
    }

    public List<User> getAdultUsers() {
        return users.stream()
                .filter(u -> u.getAge().isPresent() && u.getAge().get() >= 18)
                .collect(Collectors.toList());
    }

    public List<User> getUsersByAgeRange(int minAge, int maxAge) {
        return users.stream()
                .filter(u -> u.getAge().isPresent())
                .filter(u -> u.getAge().get() >= minAge && u.getAge().get() <= maxAge)
                .collect(Collectors.toList());
    }

    public int totalCount() {
        return users.size();
    }

    public User createUser(String name, String email, Integer age) {
        User user = new User(nextId, name, email, age, null, LocalDateTime.now());
        addUser(user);
        nextId++;
        return user;
    }
}
