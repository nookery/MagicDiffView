use std::fmt;
use std::collections::HashMap;
use regex::Regex;
use chrono::{DateTime, Utc};

#[derive(Debug, Clone)]
pub struct User {
    pub id: i32,
    pub name: String,
    pub email: String,
    pub age: Option<i32>,
    pub avatar_url: Option<String>,
    pub created_at: DateTime<Utc>,
}

lazy_static::lazy_static! {
    static ref EMAIL_REGEX: Regex = Regex::new(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    ).unwrap();
}

impl User {
    pub fn new(id: i32, name: String, email: String) -> Self {
        User {
            id,
            name,
            email,
            age: None,
            avatar_url: None,
            created_at: Utc::now(),
        }
    }

    pub fn with_details(
        id: i32,
        name: String,
        email: String,
        age: Option<i32>,
        avatar_url: Option<String>,
    ) -> Self {
        User {
            id,
            name,
            email,
            age,
            avatar_url,
            created_at: Utc::now(),
        }
    }

    pub fn validate(&self) -> bool {
        if self.name.trim().is_empty() {
            return false;
        }

        if self.email.trim().is_empty() {
            return false;
        }

        if !EMAIL_REGEX.is_match(&self.email) {
            return false;
        }

        if let Some(age) = self.age {
            if age < 13 || age > 120 {
                return false;
            }
        }

        true
    }

    pub fn display_name(&self) -> String {
        if self.name.is_empty() {
            "Unknown".to_string()
        } else {
            self.name.clone()
        }
    }

    pub fn initials(&self) -> String {
        self.name
            .split_whitespace()
            .filter_map(|word| word.chars().next())
            .collect::<String>()
            .to_uppercase()
    }

    pub fn to_map(&self) -> HashMap<String, String> {
        let mut map = HashMap::new();
        map.insert("id".to_string(), self.id.to_string());
        map.insert("name".to_string(), self.name.clone());
        map.insert("email".to_string(), self.email.clone());
        map.insert("created_at".to_string(), self.created_at.to_rfc3339());

        if let Some(age) = self.age {
            map.insert("age".to_string(), age.to_string());
        }

        if let Some(ref avatar_url) = self.avatar_url {
            map.insert("avatar_url".to_string(), avatar_url.clone());
        }

        map
    }
}

impl fmt::Display for User {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut display = format!("User({}): {} <{}>", self.id, self.name, self.email);

        if let Some(age) = self.age {
            display.push_str(&format!(" [{} 岁]", age));
        }

        write!(f, "{}", display)
    }
}

pub struct UserManager {
    users: Vec<User>,
    next_id: i32,
}

impl UserManager {
    pub fn new() -> Self {
        UserManager {
            users: Vec::new(),
            next_id: 1,
        }
    }

    pub fn add_user(&mut self, user: User) -> bool {
        if self.users.iter().any(|u| u.email == user.email) {
            return false;
        }

        self.users.push(user);
        true
    }

    pub fn find_user(&self, id: i32) -> Option<&User> {
        self.users.iter().find(|u| u.id == id)
    }

    pub fn find_user_by_email(&self, email: &str) -> Option<&User> {
        self.users.iter().find(|u| u.email == email)
    }

    pub fn remove_user(&mut self, id: i32) -> bool {
        let initial_len = self.users.len();

        if let Some(pos) = self.users.iter().position(|u| u.id == id) {
            self.users.remove(pos);
            return true;
        }

        false
    }

    pub fn update_user(
        &mut self,
        id: i32,
        name: Option<String>,
        email: Option<String>,
        age: Option<i32>,
    ) -> bool {
        if let Some(user) = self.users.iter_mut().find(|u| u.id == id) {
            if let Some(name) = name {
                user.name = name;
            }

            if let Some(email) = email {
                user.email = email;
            }

            if let Some(age) = age {
                user.age = Some(age);
            }

            true
        } else {
            false
        }
    }

    pub fn sorted_users(&self) -> Vec<&User> {
        let mut sorted = self.users.iter().collect::<Vec<_>>();
        sorted.sort_by(|a, b| a.name.cmp(&b.name));
        sorted
    }

    pub fn adult_users(&self) -> Vec<&User> {
        self.users
            .iter()
            .filter(|u| u.age.map_or(false, |age| age >= 18))
            .collect()
    }

    pub fn users_by_age_range(&self, min_age: i32, max_age: i32) -> Vec<&User> {
        self.users
            .iter()
            .filter(|u| {
                u.age
                    .map_or(false, |age| age >= min_age && age <= max_age)
            })
            .collect()
    }

    pub fn total_count(&self) -> usize {
        self.users.len()
    }

    pub fn create_user(
        &mut self,
        name: String,
        email: String,
        age: Option<i32>,
    ) -> User {
        let user = User::with_details(self.next_id, name, email, age, None);

        self.add_user(user.clone());
        self.next_id += 1;

        user
    }
}

impl Default for UserManager {
    fn default() -> Self {
        Self::new()
    }
}
