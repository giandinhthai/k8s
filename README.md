# Microservices Demo với Kubernetes

Dự án demo microservices sử dụng Go và Kubernetes, bao gồm 2 services với Kustomize để quản lý multi-environment.

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
└── k8s/               # Kubernetes manifests với Kustomize
    ├── base/          # Base manifests dùng chung
    │   ├── hello/     # Hello service base
    │   │   ├── deployment.yaml
    │   │   ├── service.yaml
    │   │   ├── config.yaml
    │   │   ├── secret.yaml
    │   │   └── kustomization.yaml
    │   ├── greet/     # Greet service base
    │   │   ├── deployment.yaml
    │   │   ├── service.yaml
    │   │   └── kustomization.yaml
    │   └── kustomization.yaml
    └── overlays/      # Environment-specific overlays
        ├── dev/       # Development environment
        │   ├── kustomization.yaml
        │   ├── hello-patch.yaml
        │   └── greet-patch.yaml
        └── prod/      # Production environment
            ├── kustomization.yaml
            ├── hello-patch.yaml
            └── greet-patch.yaml
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

## 🛠️ Build và Deploy

### Cách 1: Sử dụng Kustomize (Khuyến nghị)

```bash
# Cấu hình Docker environment cho minikube
eval $(minikube docker-env)

# Build images
make build

# Deploy to dev environment
make deploy-dev

# Deploy to prod environment  
make deploy-prod

# Preview manifests trước khi apply
make preview-dev
make preview-prod
```

### Cách 2: Legacy deployment (Cũ)

```bash
# Deploy to Kubernetes (legacy)
make deploy
```

## 🌐 Test Services

```bash
# Lấy URL services
minikube service dev-hello-service --url
minikube service dev-greet-service --url

# Test endpoints
curl http://192.168.49.2:30001
curl http://192.168.49.2:30002/greet
```

## 🔗 Kết nối giữa Services

- **greet-app** gọi **hello-service** thông qua environment variables tự động của Kubernetes
- Cả hai services chạy trong cùng namespace và có thể giao tiếp với nhau
- Sử dụng Kubernetes Service Discovery để resolve hostname
- **Không hardcode IP** - sử dụng env vars tự động

## 📋 Kustomize Commands

```bash
# Preview dev environment
kustomize build k8s/overlays/dev

# Preview prod environment
kustomize build k8s/overlays/prod

# Apply dev environment
kubectl apply -k k8s/overlays/dev

# Apply prod environment
kubectl apply -k k8s/overlays/prod

# Delete dev environment
kubectl delete -k k8s/overlays/dev

# Delete prod environment
kubectl delete -k k8s/overlays/prod
```

## 🎯 Environment Differences

### Development Environment
- **Replicas**: hello-app: 2, greet-app: 1
- **Image tags**: `:dev`
- **Log level**: `debug`
- **Resources**: Default (no limits)

### Production Environment
- **Replicas**: hello-app: 3, greet-app: 2
- **Image tags**: `:prod`
- **Log level**: `info`
- **Resources**: CPU/Memory limits set

## 📋 Best Practices

### ✅ Đúng chuẩn K8s:
- Sử dụng environment variables tự động của Kubernetes
- Không hardcode IP addresses hoặc service URLs
- ConfigMap cho configuration data
- Secret cho sensitive data
- Fallback về DNS name cho development
- Kustomize cho multi-environment management

### ❌ Tránh:
- Hardcode IP addresses trong code
- Hardcode service URLs
- Sử dụng IP trực tiếp thay vì service name

## 📋 Yêu cầu

- Docker
- Minikube
- kubectl
- Go 1.22+
- Kustomize (optional, for advanced usage) 