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
