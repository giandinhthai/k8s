.PHONY: build deploy test clean

# Build all images
build:
	@echo "Building Docker images..."
	docker build -t hello-go:latest ./hello-app
	docker build -t greet-app:latest ./greet-app
	@echo "Build completed!"

# Deploy to Kubernetes
deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/
	@echo "Deployment completed!"

# Build and deploy
all: build deploy

# Test services
test:
	@echo "Testing services..."
	@echo "Hello Service:"
	@curl -s http://192.168.49.2:30001 || echo "Hello service not accessible"
	@echo ""
	@echo "Greet Service:"
	@curl -s http://192.168.49.2:30002/greet || echo "Greet service not accessible"

# Get service URLs
urls:
	@echo "Service URLs:"
	@echo "Hello Service: $(shell minikube service hello-service --url)"
	@echo "Greet Service: $(shell minikube service greet-service --url)"

# Check status
status:
	@echo "Pod Status:"
	@kubectl get pods
	@echo ""
	@echo "Service Status:"
	@kubectl get services

# Clean up
clean:
	@echo "Cleaning up..."
	kubectl delete -f k8s/ || true
	@echo "Cleanup completed!"

# Setup minikube environment
setup:
	@echo "Setting up minikube environment..."
	eval $$(minikube docker-env)
	@echo "Environment setup completed!" 