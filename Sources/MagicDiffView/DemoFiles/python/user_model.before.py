from typing import List, Optional


class User:
    def __init__(self, user_id: int, name: str, email: str):
        self.id = user_id
        self.name = name
        self.email = email

    def validate(self) -> bool:
        return bool(self.name and self.email)

    def __str__(self) -> str:
        return f"User({self.id}): {self.name} <{self.email}>"

    def __repr__(self) -> str:
        return self.__str__()


class UserManager:
    def __init__(self):
        self.users: List[User] = []

    def add_user(self, user: User) -> None:
        self.users.append(user)

    def find_user(self, user_id: int) -> Optional[User]:
        for user in self.users:
            if user.id == user_id:
                return user
        return None

    def remove_user(self, user_id: int) -> bool:
        initial_count = len(self.users)
        self.users = [u for u in self.users if u.id != user_id]
        return len(self.users) < initial_count

    def total_count(self) -> int:
        return len(self.users)
