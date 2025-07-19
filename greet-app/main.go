package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func main() {
	// Sử dụng environment variables tự động của Kubernetes
	// Kubernetes tự động tạo: HELLO_SERVICE_SERVICE_HOST và HELLO_SERVICE_SERVICE_PORT
	k8sHost := os.Getenv("HELLO_SERVICE_SERVICE_HOST")
	k8sPort := os.Getenv("HELLO_SERVICE_SERVICE_PORT")

	targetServiceURL := fmt.Sprintf("http://%s:%s", k8sHost, k8sPort)

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
	fmt.Printf("K8s auto-generated vars: HELLO_SERVICE_SERVICE_HOST=%s, HELLO_SERVICE_SERVICE_PORT=%s\n", 
		os.Getenv("HELLO_SERVICE_SERVICE_HOST"), os.Getenv("HELLO_SERVICE_SERVICE_PORT"))
	log.Fatal(http.ListenAndServe(":8081", nil))
} 