package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	message := os.Getenv("APP_MESSAGE")
	apiKey := os.Getenv("API_KEY")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Message: %s\nAPI Key: %s\n", message, apiKey)
	})

	fmt.Println("Starting server at :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
