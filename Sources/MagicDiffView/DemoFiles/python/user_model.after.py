from typing import List, Optional
from datetime import datetime
from dataclasses import dataclass, field
from email.utils import parseaddr
import re


@dataclass
class User:
    id: int
    name: str
    email: str
    age: Optional[int] = None
    avatar_url: Optional[str] = None
    created_at: datetime = field(default_factory=datetime.now)

    def validate(self) -> bool:
        """验证用户数据"""
        if not self.name or not self.name.strip():
            return False

        if not self.email or not self.email.strip():
            return False

        # 验证邮箱格式
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, self.email):
            return False

        # 验证年龄
        if self.age is not None and (self.age < 13 or self.age > 120):
            return False

        return True

    def __str__(self) -> str:
        info = f"User({self.id}): {self.name} <{self.email}>"
        if self.age is not None:
            info += f" [{self.age}岁]"
        return info

    def __repr__(self) -> str:
        return self.__str__()

    @property
    def display_name(self) -> str:
        """获取显示名称"""
        return self.name if self.name else "Unknown"

    @property
    def initials(self) -> str:
        """获取姓名首字母"""
        return ''.join(
            word[0].upper()
            for word in self.name.split()
            if word
        )

    def to_dict(self) -> dict:
        """转换为字典"""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'age': self.age,
            'avatar_url': self.avatar_url,
            'created_at': self.created_at.isoformat()
        }


class UserManager:
    def __init__(self):
        self.users: List[User] = []
        self._next_id: int = 1

    def add_user(self, user: User) -> bool:
        """添加用户，如果邮箱已存在则返回 False"""
        if any(u.email == user.email for u in self.users):
            return False
        self.users.append(user)
        return True

    def find_user(self, user_id: int) -> Optional[User]:
        """根据 ID 查找用户"""
        return next((u for u in self.users if u.id == user_id), None)

    def find_user_by_email(self, email: str) -> Optional[User]:
        """根据邮箱查找用户"""
        return next((u for u in self.users if u.email == email), None)

    def remove_user(self, user_id: int) -> bool:
        """删除用户，成功返回 True"""
        for i, user in enumerate(self.users):
            if user.id == user_id:
                self.users.pop(i)
                return True
        return False

    def update_user(
        self,
        user_id: int,
        name: Optional[str] = None,
        email: Optional[str] = None,
        age: Optional[int] = None
    ) -> bool:
        """更新用户信息"""
        user = self.find_user(user_id)
        if not user:
            return False

        if name is not None:
            user.name = name
        if email is not None:
            user.email = email
        if age is not None:
            user.age = age

        return True

    @property
    def sorted_users(self) -> List[User]:
        """按姓名排序的用户列表"""
        return sorted(self.users, key=lambda u: u.name)

    @property
    def adult_users(self) -> List[User]:
        """获取成年用户列表"""
        return [u for u in self.users if u.age is not None and u.age >= 18]

    def total_count(self) -> int:
        """获取用户总数"""
        return len(self.users)

    def get_users_by_age_range(self, min_age: int, max_age: int) -> List[User]:
        """获取指定年龄范围的用户"""
        return [
            u for u in self.users
            if u.age is not None and min_age <= u.age <= max_age
        ]

    def create_user(
        self,
        name: str,
        email: str,
        age: Optional[int] = None
    ) -> User:
        """创建并添加新用户"""
        user = User(
            id=self._next_id,
            name=name,
            email=email,
            age=age
        )
        self.add_user(user)
        self._next_id += 1
        return user
