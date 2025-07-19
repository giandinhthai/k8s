.PHONY: build deploy test clean deploy-dev deploy-prod preview-dev preview-prod

# Build all images
build:
	@echo "Building Docker images..."
	docker build -t hello-app:latest ./hello-app
	docker build -t greet-app:latest ./greet-app
	@echo "Build completed!"

# Deploy to Kubernetes (legacy - using old k8s structure)
deploy:
	@echo "Deploying to Kubernetes (legacy)..."
	kubectl apply -f k8s/
	@echo "Deployment completed!"

# Deploy to dev environment using Kustomize
deploy-dev:
	@echo "Deploying to dev environment..."
	kubectl apply -k k8s/overlays/dev
	@echo "Dev deployment completed!"

# Deploy to prod environment using Kustomize
deploy-prod:
	@echo "Deploying to prod environment..."
	kubectl apply -k k8s/overlays/prod
	@echo "Prod deployment completed!"

# Preview dev environment
preview-dev:
	@echo "Previewing dev environment..."
	kustomize build k8s/overlays/dev

# Preview prod environment
preview-prod:
	@echo "Previewing prod environment..."
	kustomize build k8s/overlays/prod

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

# Clean up dev environment
clean-dev:
	@echo "Cleaning up dev environment..."
	kubectl delete -k k8s/overlays/dev || true
	@echo "Dev cleanup completed!"

# Clean up prod environment
clean-prod:
	@echo "Cleaning up prod environment..."
	kubectl delete -k k8s/overlays/prod || true
	@echo "Prod cleanup completed!"

# Setup minikube environment
setup:
	@echo "Setting up minikube environment..."
	eval $$(minikube docker-env)
	@echo "Environment setup completed!" 