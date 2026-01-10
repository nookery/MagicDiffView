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

    async postData(endpoint, data, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const requestOptions = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...this.headers,
                ...options.headers
            },
            body: JSON.stringify(data),
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

            const responseData = await response.json();
            this._logSuccess('POST', endpoint, response.status);
            return responseData;
        } catch (error) {
            this._logError('Post error', endpoint, error);
            throw error;
        }
    }

    async putData(endpoint, data, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const requestOptions = {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                ...this.headers,
                ...options.headers
            },
            body: JSON.stringify(data),
            ...options
        };

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

        return await response.json();
    }

    async deleteData(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const requestOptions = {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                ...this.headers,
                ...options.headers
            },
            ...options
        };

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

        return response.status === 204 ? null : await response.json();
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

                if (error.name === 'AbortError') {
                    console.warn(`Attempt ${attempt + 1} timed out, retrying...`);
                } else {
                    console.warn(`Attempt ${attempt + 1} failed: ${error.message}`);
                }

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

    setHeader(key, value) {
        this.headers[key] = value;
    }

    removeHeader(key) {
        delete this.headers[key];
    }

    setAuthToken(token) {
        this.setHeader('Authorization', `Bearer ${token}`);
    }

    clearAuth() {
        this.removeHeader('Authorization');
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

// 使用示例
const api = new APIService('https://api.example.com', {
    timeout: 10000,
    enableRetry: true,
    maxRetries: 3
});

api.setAuthToken('your-token-here');

api.fetchData('/users')
    .then(data => {
        console.log('Users:', data);
    })
    .catch(error => {
        if (error instanceof APIError) {
            console.error(`API Error (${error.status}):`, error.message);
        } else {
            console.error('Error:', error);
        }
    });

api.postData('/users', {
    name: 'John Doe',
    email: 'john@example.com'
})
    .then(data => {
        console.log('Created user:', data);
    })
    .catch(error => {
        console.error('Failed to create user:', error);
    });
