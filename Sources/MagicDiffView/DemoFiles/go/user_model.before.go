package main

import "fmt"

type User struct {
	ID    int
	Name  string
	Email string
}

func (u *User) Validate() bool {
	return u.Name != "" && u.Email != ""
}

func (u *User) String() string {
	return fmt.Sprintf("User(%d): %s <%s>", u.ID, u.Name, u.Email)
}

type UserManager struct {
	users []User
}

func (m *UserManager) AddUser(user User) {
	m.users = append(m.users, user)
}

func (m *UserManager) FindUser(id int) *User {
	for i := range m.users {
		if m.users[i].ID == id {
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

func (m *UserManager) TotalCount() int {
	return len(m.users)
}
