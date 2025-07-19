package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func main() {
	// Sử dụng environment variable để xác định service name
	// Có thể được set từ Kustomize overlay hoặc Kubernetes
	serviceName := os.Getenv("HELLO_SERVICE_NAME")

	// Sử dụng environment variable để xác định port
	servicePort := os.Getenv("HELLO_SERVICE_PORT")
	
	// Tạo URL từ service name và port
	targetServiceURL := fmt.Sprintf("http://%s:%s", serviceName, servicePort)

	http.HandleFunc("/greet", func(w http.ResponseWriter, r *http.Request) {
		resp, err := http.Get(targetServiceURL)
		if err != nil {
			http.Error(w, fmt.Sprintf("Failed to reach hello-service at %s: %v", targetServiceURL, err), http.StatusInternalServerError)
			return
		}
		defer resp.Body.Close()
		body, _ := io.ReadAll(resp.Body)
		fmt.Fprintf(w, "Greeted by hello-service: %s", string(body))
	})

	fmt.Printf("Starting greet service at :8081\n")
	fmt.Printf("Target service URL: %s\n", targetServiceURL)
	log.Fatal(http.ListenAndServe(":8081", nil))
} 