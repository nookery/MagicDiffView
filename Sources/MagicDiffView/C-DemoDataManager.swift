import Foundation

// MARK: - Demo File Models

/// 演示文件数据结构
public struct DemoFile: Identifiable, Hashable {
    public let id = UUID()
    public let language: DemoCodeLanguage
    public let name: String
    public let description: String
    public let beforeContent: String
    public let afterContent: String

    public init(
        language: DemoCodeLanguage,
        name: String,
        description: String,
        beforeContent: String,
        afterContent: String
    ) {
        self.language = language
        self.name = name
        self.description = description
        self.beforeContent = beforeContent
        self.afterContent = afterContent
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DemoFile, rhs: DemoFile) -> Bool {
        lhs.id == rhs.id
    }
}

/// 演示文件支持的编程语言
public enum DemoCodeLanguage: String, CaseIterable {
    case swift = "Swift"
    case javascript = "JavaScript"
    case python = "Python"
    case java = "Java"
    case kotlin = "Kotlin"
    case go = "Go"
    case rust = "Rust"

    public var icon: String {
        switch self {
        case .swift: return "swift"
        case .javascript: return "javascript"
        case .python: return "python"
        case .java: return "java"
        case .kotlin: return "kotlin"
        case .go: return "globe"
        case .rust: return "gear"
        }
    }

    /// 转换为语法高亮的 CodeLanguage
    public var syntaxLanguage: CodeLanguage {
        switch self {
        case .swift: return .swift
        case .javascript: return .javascript
        case .python: return .python
        case .java: return .java
        case .kotlin, .go, .rust: return .plainText
        }
    }
}

// MARK: - Demo Content Enums

/// Swift 演示代码
enum SwiftDemos {
    static let userModelBefore =
"""
import Foundation

struct User {
    let id: Int
    let name: String
    let email: String

    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    func validate() -> Bool {
        return !name.isEmpty && !email.isEmpty
    }

    func description() -> String {
        return "User(\\(id)): \\(name) <\\(email)>"
    }
}

class UserManager {
    var users: [User] = []

    func addUser(_ user: User) {
        users.append(user)
    }

    func findUser(id: Int) -> User? {
        return users.first { $0.id == id }
    }

    func removeUser(id: Int) -> Bool {
        let initialCount = users.count
        users.removeAll { $0.id == id }
        return users.count < initialCount
    }
}
"""

    static let userModelAfter =
"""
import Foundation

struct User {
    let id: Int
    let name: String
    let email: String
    let age: Int?
    let avatarURL: URL?
    let createdAt: Date

    init(
        id: Int,
        name: String,
        email: String,
        age: Int? = nil,
        avatarURL: URL? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }

    func validate() -> Bool {
        guard !name.isEmpty else { return false }
        guard !email.isEmpty else { return false }
        guard email.contains("@") && email.contains(".") else { return false }
        guard let age = age else { return true }
        return age >= 13 && age <= 120
    }

    func description() -> String {
        var info = "User(\\(id)): \\(name) <\\(email)>"
        if let age = age {
            info += " [\\(age)岁]"
        }
        return info
    }

    var displayName: String {
        name.isEmpty ? "Unknown" : name
    }

    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.uppercased().joined()
    }
}

class UserManager {
    private(set) var users: [User] = []
    private var nextID: Int = 1

    func addUser(_ user: User) -> Bool {
        guard !users.contains(where: { $0.email == user.email }) else {
            return false
        }
        users.append(user)
        return true
    }

    func findUser(id: Int) -> User? {
        return users.first { $0.id == id }
    }

    func findUser(email: String) -> User? {
        return users.first { $0.email == email }
    }

    func removeUser(id: Int) -> Bool {
        let index = users.firstIndex { $0.id == id }
        guard let index = index else { return false }
        users.remove(at: index)
        return true
    }

    func updateUser(id: Int, name: String? = nil, email: String? = nil) -> Bool {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            return false
        }
        if let name = name {
            users[index].name = name
        }
        if let email = email {
            users[index].email = email
        }
        return true
    }

    var sortedUsers: [User] {
        return users.sorted { $0.name < $1.name }
    }

    var adultUsers: [User] {
        return users.filter { $0.age ?? 0 >= 18 }
    }

    func totalCount() -> Int {
        return users.count
    }
}
"""
}

/// JavaScript 演示代码
enum JavaScriptDemos {
    static let apiServiceBefore =
"""
// API 服务类
class APIService {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
        this.timeout = 5000;
    }

    async fetchData(endpoint) {
        const url = `${this.baseUrl}${endpoint}`;
        const options = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        };

        try {
            const response = await fetch(url, options);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return await response.json();
        } catch (error) {
            console.error('Fetch error:', error);
            throw error;
        }
    }

    async postData(endpoint, data) {
        const url = `${this.baseUrl}${endpoint}`;
        const options = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        };

        try {
            const response = await fetch(url, options);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return await response.json();
        } catch (error) {
            console.error('Post error:', error);
            throw error;
        }
    }

    setTimeout(callback, delay) {
        setTimeout(callback, delay);
    }
}

// 使用示例
const api = new APIService('https://api.example.com');

api.fetchData('/users').then(data => {
    console.log('Users:', data);
}).catch(error => {
    console.error('Error:', error);
});
"""

    static let apiServiceAfter =
"""
// API 服务类 - 增强版
class APIService {
    constructor(baseUrl, options = {}) {
        this.baseUrl = baseUrl;
        this.timeout = options.timeout || 5000;
        this.headers = options.headers || {};
        this.enableRetry = options.enableRetry ?? true;
        this.maxRetries = options.maxRetries || 3;
        this.retryDelay = options.retryDelay || 1000;
    }

    async fetchData(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const requestOptions = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                ...this.headers,
                ...options.headers
            },
            ...options
        };

        try {
            const response = await this._executeWithRetry(
                () => fetch(url, requestOptions),
                endpoint
            );

            if (!response.ok) {
                throw new APIError(
                    `HTTP error! status: ${response.status}`,
                    response.status,
                    endpoint
                );
            }

            const data = await response.json();
            this._logSuccess('GET', endpoint, response.status);
            return data;
        } catch (error) {
            this._logError('Fetch error', endpoint, error);
            throw error;
        }
    }

    async _executeWithRetry(requestFn, endpoint) {
        let lastError;

        for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
            try {
                return await requestFn();
            } catch (error) {
                lastError = error;

                if (!this.enableRetry || attempt === this.maxRetries) {
                    throw error;
                }

                console.warn(`Attempt ${attempt + 1} failed, retrying...`);
                await this._delay(this.retryDelay * (attempt + 1));
            }
        }

        throw lastError;
    }

    _delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    _logSuccess(method, endpoint, status) {
        if (this.verbose) {
            console.log(`✓ ${method} ${endpoint} - ${status}`);
        }
    }

    _logError(message, endpoint, error) {
        console.error(`✗ ${message}: ${endpoint}`, error);
    }

    setAuthToken(token) {
        this.headers['Authorization'] = `Bearer ${token}`;
    }
}

class APIError extends Error {
    constructor(message, status, endpoint) {
        super(message);
        this.name = 'APIError';
        this.status = status;
        this.endpoint = endpoint;
    }
}
"""
}

/// Python 演示代码
enum PythonDemos {
    static let userModelBefore =
"""
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
"""

    static let userModelAfter =
"""
from typing import List, Optional
from datetime import datetime
from dataclasses import dataclass, field
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
        if not self.name or not self.name.strip():
            return False
        if not self.email or not self.email.strip():
            return False

        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, self.email):
            return False

        if self.age is not None and (self.age < 13 or self.age > 120):
            return False

        return True

    @property
    def display_name(self) -> str:
        return self.name if self.name else "Unknown"

    @property
    def initials(self) -> str:
        return ''.join(
            word[0].upper()
            for word in self.name.split()
            if word
        )


class UserManager:
    def __init__(self):
        self.users: List[User] = []
        self._next_id: int = 1

    def add_user(self, user: User) -> bool:
        if any(u.email == user.email for u in self.users):
            return False
        self.users.append(user)
        return True

    def find_user_by_email(self, email: str) -> Optional[User]:
        return next((u for u in self.users if u.email == email), None)

    def update_user(
        self,
        user_id: int,
        name: Optional[str] = None,
        email: Optional[str] = None
    ) -> bool:
        user = self.find_user(user_id)
        if not user:
            return False

        if name is not None:
            user.name = name
        if email is not None:
            user.email = email

        return True

    @property
    def sorted_users(self) -> List[User]:
        return sorted(self.users, key=lambda u: u.name)

    @property
    def adult_users(self) -> List[User]:
        return [u for u in self.users if u.age is not None and u.age >= 18]
"""
}

/// Java 演示代码
enum JavaDemos {
    static let userModelBefore =
"""
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

    public boolean validate() {
        return name != null && !name.isEmpty()
                && email != null && !email.isEmpty();
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
}
"""

    static let userModelAfter =
"""
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class User {
    private int id;
    private String name;
    private String email;
    private Integer age;

    public boolean validate() {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailPattern = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}$";
        if (!email.matches(emailPattern)) {
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
}

class UserManager {
    private final List<User> users = new ArrayList<>();

    public boolean addUser(User user) {
        if (users.stream().anyMatch(u -> u.getEmail().equals(user.getEmail()))) {
            return false;
        }
        users.add(user);
        return true;
    }

    public Optional<User> findUserByEmail(String email) {
        return users.stream()
                .filter(u -> u.getEmail().equals(email))
                .findFirst();
    }

    public List<User> getSortedUsers() {
        return users.stream()
                .sorted((u1, u2) -> u1.getName().compareTo(u2.getName()))
                .collect(Collectors.toList());
    }

    public List<User> getAdultUsers() {
        return users.stream()
                .filter(u -> u.getAge() != null && u.getAge() >= 18)
                .collect(Collectors.toList());
    }
}
"""
}

/// Kotlin 演示代码
enum KotlinDemos {
    static let userModelBefore =
"""
data class User(
    val id: Int,
    val name: String,
    val email: String
) {
    fun validate(): Boolean {
        return name.isNotEmpty() && email.isNotEmpty()
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
}
"""

    static let userModelAfter =
"""
import java.time.LocalDateTime

data class User(
    val id: Int,
    val name: String,
    val email: String,
    val age: Int? = null,
    val avatarUrl: String? = null,
    val createdAt: LocalDateTime = LocalDateTime.now()
) {
    fun validate(): Boolean {
        if (name.isBlank()) return false
        if (email.isBlank()) return false

        val emailPattern = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}$"
        if (!email.matches(emailPattern.toRegex())) return false

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
}

class UserManager {
    private val users: MutableList<User> = mutableListOf()

    fun addUser(user: User): Boolean {
        if (users.any { it.email == user.email }) {
            return false
        }
        users.add(user)
        return true
    }

    val sortedUsers: List<User>
        get() = users.sortedBy { it.name }

    val adultUsers: List<User>
        get() = users.filter { it.age != null && it.age!! >= 18 }
}
"""
}

/// Go 演示代码
enum GoDemos {
    static let userModelBefore =
"""
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
"""

    static let userModelAfter =
"""
package main

import (
    "fmt"
    "regexp"
    "sort"
    "strings"
)

type User struct {
    ID        int
    Name      string
    Email     string
    Age       *int
    AvatarURL *string
}

var emailPattern = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\\\.[a-zA-Z]{2,}$`)

func (u *User) Validate() bool {
    if strings.TrimSpace(u.Name) == "" {
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

type UserManager struct {
    users   []User
    nextID  int
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
"""
}

/// Rust 演示代码

/// Rust 演示代码
enum RustDemos {
    static let userModelBefore =
"""
use std::fmt;

#[derive(Debug, Clone)]
pub struct User {
    pub id: i32,
    pub name: String,
    pub email: String,
}

impl User {
    pub fn validate(&self) -> bool {
        !self.name.is_empty() && !self.email.is_empty()
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
}
"""

    static let userModelAfter =
"""
use std::collections::HashMap;
use regex::Regex;

#[derive(Debug, Clone)]
pub struct User {
    pub id: i32,
    pub name: String,
    pub email: String,
    pub age: Option<i32>,
    pub avatar_url: Option<String>,
}

impl User {
    pub fn validate(&self) -> bool {
        if self.name.trim().is_empty() {
            return false;
        }
        if self.email.trim().is_empty() {
            return false;
        }

        let email_regex = Regex::new(
            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        ).unwrap();

        if !email_regex.is_match(&self.email) {
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
}
"""
}

// MARK: - Demo Data Manager

/// 演示数据管理器
public class DemoDataManager {
    public static let shared = DemoDataManager()

    @Published public private(set) var demoFiles: [DemoFile] = []

    private init() {
        loadDemoFiles()
    }

    /// 加载所有演示文件
    public func loadDemoFiles() {
        demoFiles = [
            DemoFile(
                language: .swift,
                name: "UserModel",
                description: "用户模型重构：添加年龄、头像、日期等字段，增强验证和工具方法",
                beforeContent: SwiftDemos.userModelBefore,
                afterContent: SwiftDemos.userModelAfter
            ),
            DemoFile(
                language: .javascript,
                name: "APIService",
                description: "API 服务增强：添加重试机制、错误处理、多种 HTTP 方法支持",
                beforeContent: JavaScriptDemos.apiServiceBefore,
                afterContent: JavaScriptDemos.apiServiceAfter
            ),
            DemoFile(
                language: .python,
                name: "UserModel",
                description: "用户模型升级：使用 dataclass，添加验证、查询方法和数据序列化",
                beforeContent: PythonDemos.userModelBefore,
                afterContent: PythonDemos.userModelAfter
            ),
            DemoFile(
                language: .java,
                name: "UserModel",
                description: "用户模型完善：添加可选字段、邮箱验证、流式处理和工厂方法",
                beforeContent: JavaDemos.userModelBefore,
                afterContent: JavaDemos.userModelAfter
            ),
            DemoFile(
                language: .kotlin,
                name: "UserModel",
                description: "用户模型增强：利用 Kotlin 特性，添加不可变性、扩展函数和集合操作",
                beforeContent: KotlinDemos.userModelBefore,
                afterContent: KotlinDemos.userModelAfter
            ),
            DemoFile(
                language: .go,
                name: "UserModel",
                description: "用户模型扩展：添加可选字段、正则验证、排序和查询方法",
                beforeContent: GoDemos.userModelBefore,
                afterContent: GoDemos.userModelAfter
            ),
            DemoFile(
                language: .rust,
                name: "UserModel",
                description: "用户模型改进：利用所有权系统、Option 类型和迭代器",
                beforeContent: RustDemos.userModelBefore,
                afterContent: RustDemos.userModelAfter
            ),
        ]
    }

    /// 根据语言筛选演示文件
    public func filterFiles(by language: DemoCodeLanguage?) -> [DemoFile] {
        guard let language = language else {
            return demoFiles
        }
        return demoFiles.filter { $0.language == language }
    }

    /// 搜索演示文件
    public func searchFiles(query: String) -> [DemoFile] {
        guard !query.isEmpty else {
            return demoFiles
        }

        return demoFiles.filter { file in
            file.name.localizedCaseInsensitiveContains(query) ||
            file.description.localizedCaseInsensitiveContains(query) ||
            file.language.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    /// 获取特定语言的文件数量
    public func countFiles(for language: DemoCodeLanguage) -> Int {
        demoFiles.filter { $0.language == language }.count
    }

    /// 获取所有可用语言的列表
    public var availableLanguages: [DemoCodeLanguage] {
        DemoCodeLanguage.allCases
    }

    /// 获取演示文件的统计信息
    public var statistics: DemoStatistics {
        let languageCounts = Dictionary(grouping: demoFiles, by: { $0.language })
            .mapValues { $0.count }

        return DemoStatistics(
            totalFiles: demoFiles.count,
            languageCounts: languageCounts,
            totalLines: demoFiles.reduce(0) { $0 + countLines(in: $1.beforeContent + $1.afterContent) }
        )
    }

    /// 计算代码行数
    private func countLines(in text: String) -> Int {
        text.components(separatedBy: .newlines).count
    }
}

/// 演示文件统计信息
public struct DemoStatistics {
    public let totalFiles: Int
    public let languageCounts: [DemoCodeLanguage: Int]
    public let totalLines: Int
}

// MARK: - Combine Support

import Combine

extension DemoDataManager: ObservableObject {}
