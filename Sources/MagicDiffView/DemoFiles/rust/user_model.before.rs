use std::fmt;

#[derive(Debug, Clone)]
pub struct User {
    pub id: i32,
    pub name: String,
    pub email: String,
}

impl User {
    pub fn new(id: i32, name: String, email: String) -> Self {
        User { id, name, email }
    }

    pub fn validate(&self) -> bool {
        !self.name.is_empty() && !self.email.is_empty()
    }
}

impl fmt::Display for User {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "User({}): {} <{}>", self.id, self.name, self.email)
    }
}

pub struct UserManager {
    users: Vec<User>,
}

impl UserManager {
    pub fn new() -> Self {
        UserManager { users: Vec::new() }
    }

    pub fn add_user(&mut self, user: User) {
        self.users.push(user);
    }

    pub fn find_user(&self, id: i32) -> Option<&User> {
        self.users.iter().find(|u| u.id == id)
    }

    pub fn remove_user(&mut self, id: i32) -> bool {
        let initial_len = self.users.len();
        self.users.retain(|u| u.id != id);
        self.users.len() < initial_len
    }

    pub fn total_count(&self) -> usize {
        self.users.len()
    }
}

impl Default for UserManager {
    fn default() -> Self {
        Self::new()
    }
}
