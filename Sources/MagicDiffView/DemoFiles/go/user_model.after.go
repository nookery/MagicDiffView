package main

import (
	"fmt"
	"regexp"
	"sort"
	"strings"
	"time"
)

type User struct {
	ID        int
	Name      string
	Email     string
	Age       *int // 使用指针表示可选字段
	AvatarURL *string
	CreatedAt time.Time
}

var emailPattern = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

func (u *User) Validate() bool {
	if strings.TrimSpace(u.Name) == "" {
		return false
	}

	if strings.TrimSpace(u.Email) == "" {
		return false
	}

	if !emailPattern.MatchString(u.Email) {
		return false
	}

	if u.Age != nil && (*u.Age < 13 || *u.Age > 120) {
		return false
	}

	return true
}

func (u *User) DisplayName() string {
	if u.Name == "" {
		return "Unknown"
	}
	return u.Name
}

func (u *User) Initials() string {
	parts := strings.Fields(u.Name)
	var initials []rune
	for _, part := range parts {
		if len(part) > 0 {
			initials = append(initials, rune(part[0]))
		}
	}
	return strings.ToUpper(string(initials))
}

func (u *User) String() string {
	str := fmt.Sprintf("User(%d): %s <%s>", u.ID, u.Name, u.Email)
	if u.Age != nil {
		str += fmt.Sprintf(" [%d 岁]", *u.Age)
	}
	return str
}

func (u *User) ToMap() map[string]interface{} {
	result := map[string]interface{}{
		"id":         u.ID,
		"name":       u.Name,
		"email":      u.Email,
		"created_at": u.CreatedAt.Format(time.RFC3339),
	}

	if u.Age != nil {
		result["age"] = *u.Age
	}

	if u.AvatarURL != nil {
		result["avatar_url"] = *u.AvatarURL
	}

	return result
}

type UserManager struct {
	users   []User
	nextID  int
}

func NewUserManager() *UserManager {
	return &UserManager{
		users:  make([]User, 0),
		nextID: 1,
	}
}

func (m *UserManager) AddUser(user User) bool {
	for _, existingUser := range m.users {
		if existingUser.Email == user.Email {
			return false
		}
	}
	m.users = append(m.users, user)
	return true
}

func (m *UserManager) FindUser(id int) *User {
	for i := range m.users {
		if m.users[i].ID == id {
			return &m.users[i]
		}
	}
	return nil
}

func (m *UserManager) FindUserByEmail(email string) *User {
	for i := range m.users {
		if m.users[i].Email == email {
			return &m.users[i]
		}
	}
	return nil
}

func (m *UserManager) RemoveUser(id int) bool {
	for i, user := range m.users {
		if user.ID == id {
			m.users = append(m.users[:i], m.users[i+1:]...)
			return true
		}
	}
	return false
}

func (m *UserManager) UpdateUser(id int, name *string, email *string, age *int) bool {
	for i := range m.users {
		if m.users[i].ID == id {
			if name != nil {
				m.users[i].Name = *name
			}
			if email != nil {
				m.users[i].Email = *email
			}
			if age != nil {
				m.users[i].Age = age
			}
			return true
		}
	}
	return false
}

func (m *UserManager) SortedUsers() []User {
	sorted := make([]User, len(m.users))
	copy(sorted, m.users)

	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].Name < sorted[j].Name
	})

	return sorted
}

func (m *UserManager) AdultUsers() []User {
	var adults []User
	for _, user := range m.users {
		if user.Age != nil && *user.Age >= 18 {
			adults = append(adults, user)
		}
	}
	return adults
}

func (m *UserManager) GetUsersByAgeRange(minAge, maxAge int) []User {
	var result []User
	for _, user := range m.users {
		if user.Age != nil && *user.Age >= minAge && *user.Age <= maxAge {
			result = append(result, user)
		}
	}
	return result
}

func (m *UserManager) TotalCount() int {
	return len(m.users)
}

func (m *UserManager) CreateUser(name, email string, age *int) User {
	user := User{
		ID:        m.nextID,
		Name:      name,
		Email:     email,
		Age:       age,
		CreatedAt: time.Now(),
	}

	m.AddUser(user)
	m.nextID++

	return user
}
