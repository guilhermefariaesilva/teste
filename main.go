package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

const version = "0.0.3"

type BasicAuth struct {
	User     string
	Password string
}

func NewBasicAuth() (*BasicAuth, error) {
	user := os.Getenv("ADMIN_USER")
	pass := os.Getenv("ADMIN_PASS")

	if user == "" || pass == "" {
		return nil, fmt.Errorf("credentials are required [ADMIN_USER and ADMIN_PASS]")
	}

	return &BasicAuth{user, pass}, nil
}

func (b *BasicAuth) check(user string, pass string) bool {
	return b.User == user && b.Password == pass
}

func main() {
	port := os.Getenv("PORT")

	if port == "" {
		log.Println("PORT is required")
		os.Exit(1)
	}

	bauth, err := NewBasicAuth()
	if err != nil {
		log.Printf("%v\n", err)
		os.Exit(1)
	}

	mux := http.NewServeMux()
	mux.HandleFunc(`/app`, app)
	mux.HandleFunc("/admin", auth(admin, bauth))
	mux.HandleFunc("/healthz", healthz)

	log.Printf("Server listening on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}

func app(w http.ResponseWriter, r *http.Request) {
	log.Printf("Serving request: %s", r.URL.Path)
	host, _ := os.Hostname()

	w.Header().Set("Content-Type", "application/json")

	encoder := json.NewEncoder(w)
	encoder.SetIndent("", "  ")
	encoder.Encode(map[string]string{"app": "Infra Go App", "zone": "public", "version": version, "hostname": host})
}

func admin(w http.ResponseWriter, r *http.Request) {
	log.Printf("Serving request: %s", r.URL.Path)

	host, _ := os.Hostname()

	w.Header().Set("Content-Type", "application/json")

	encoder := json.NewEncoder(w)
	encoder.SetIndent("", "  ")
	encoder.Encode(map[string]string{"app": "Infra Go App", "zone": "private", "version": version, "hostname": host})
}

func healthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func auth(fn http.HandlerFunc, auth *BasicAuth) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, pass, ok := r.BasicAuth()
		if !ok || !auth.check(user, pass) {
			http.Error(w, "Unauthorized.", 401)
			return
		}
		fn(w, r)
	}
}
