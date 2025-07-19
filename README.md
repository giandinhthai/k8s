# Microservices Demo với Kubernetes

Dự án demo microservices sử dụng Go và Kubernetes, bao gồm 2 services:

## 🏗️ Cấu trúc dự án

```
hello-world-app/
├── .gitignore          # Loại trừ file không cần thiết
├── README.md           # Tài liệu dự án
├── Makefile            # Scripts build/deploy tự động
├── hello-app/          # Service A - Hello Service
│   ├── main.go
│   ├── Dockerfile
│   └── go.mod
├── greet-app/          # Service B - Greet Service  
│   ├── main.go
│   ├── Dockerfile
│   └── go.mod
└── k8s/               # Kubernetes manifests
    ├── hello-config.yaml      # ConfigMap cho hello-app
    ├── hello-secret.yaml      # Secret cho hello-app
    ├── hello-deployment.yaml  # Deployment với env vars
    ├── hello-service.yaml     # Service
    ├── greet-deployment.yaml
    └── greet-service.yaml
```

## 🚀 Các Services

### Hello Service (hello-app)
- **Port**: 8080 (internal), 30001 (external)
- **Endpoint**: `/` 
- **Response**: `Message: Hello from ConfigMap!` + `API Key: super-secret-api-key`
- **Config**: Sử dụng ConfigMap và Secret

### Greet Service (greet-app)
- **Port**: 8081 (internal), 30002 (external)
- **Endpoint**: `/greet`
- **Chức năng**: Gọi hello-service và trả về kết quả
- **Service Discovery**: Sử dụng environment variables tự động của Kubernetes

## 🔗 Service Discovery trong Kubernetes

### Environment Variables tự động (Best Practice)
Kubernetes tự động tạo ra các environment variables dựa trên service name:
```bash
HELLO_SERVICE_SERVICE_HOST=10.106.123.100
HELLO_SERVICE_SERVICE_PORT=8080
```

```go
// Sử dụng env vars tự động của Kubernetes
k8sHost := os.Getenv("HELLO_SERVICE_SERVICE_HOST")
k8sPort := os.Getenv("HELLO_SERVICE_SERVICE_PORT")

// Fallback về DNS name nếu không có env vars
if k8sHost == "" || k8sPort == "" {
    k8sHost = "hello-service"
    k8sPort = "8080"
}

targetServiceURL := fmt.Sprintf("http://%s:%s", k8sHost, k8sPort)
```

### Các cách khác (cho tham khảo):

#### Cách 1: DNS Name trực tiếp
```go
// Sử dụng DNS name trực tiếp
targetServiceURL := "http://hello-service:8080"
```

#### Cách 2: ConfigMap (Cho trường hợp phức tạp)
```yaml
# k8s/greet-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: greet-config
data:
  TARGET_SERVICE_HOST: "hello-service"
  TARGET_SERVICE_PORT: "8080"
```

## 🛠️ Build và Deploy

```bash
# Cấu hình Docker environment cho minikube
eval $(minikube docker-env)

# Build images
docker build -t hello-go:latest ./hello-app
docker build -t greet-app:latest ./greet-app

# Deploy to Kubernetes
kubectl apply -f k8s/

# Kiểm tra trạng thái
kubectl get pods
kubectl get services
```

## 🌐 Test Services

```bash
# Lấy URL services
minikube service hello-service --url
minikube service greet-service --url

# Test endpoints
curl http://192.168.49.2:30001
curl http://192.168.49.2:30002/greet
```

## 🔗 Kết nối giữa Services

- **greet-app** gọi **hello-service** thông qua environment variables tự động của Kubernetes
- Cả hai services chạy trong cùng namespace và có thể giao tiếp với nhau
- Sử dụng Kubernetes Service Discovery để resolve hostname
- **Không hardcode IP** - sử dụng env vars tự động

## 📋 Best Practices

### ✅ Đúng chuẩn K8s:
- Sử dụng environment variables tự động của Kubernetes
- Không hardcode IP addresses hoặc service URLs
- ConfigMap cho configuration data
- Secret cho sensitive data
- Fallback về DNS name cho development

### ❌ Tránh:
- Hardcode IP addresses trong code
- Hardcode service URLs
- Sử dụng IP trực tiếp thay vì service name

## 📋 Yêu cầu

- Docker
- Minikube
- kubectl
- Go 1.22+ 