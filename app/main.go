package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	jwtmiddleware "github.com/auth0/go-jwt-middleware"
	jwt "github.com/form3tech-oss/jwt-go"
	"github.com/gorilla/mux"
)

type myResponse struct {
	Message string `json:"message"`
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/ping", ping)
	r.HandleFunc("/auth", auth)
	// ミドルウェアによって守られたprivatePing
	r.Handle("/private-ping", jwtMiddleware.Handler(http.HandlerFunc(privatePing)))

	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal("サーバ起動に失敗しました。", err)
	}
}

func ping(w http.ResponseWriter, r *http.Request) {
	myResponse := &myResponse{
		Message: "pong",
	}
	json.NewEncoder(w).Encode(myResponse)
}

func privatePing(w http.ResponseWriter, r *http.Request) {
	myResponse := &myResponse{
		Message: "private pong",
	}
	json.NewEncoder(w).Encode(myResponse)
}

func auth(w http.ResponseWriter, r *http.Request) {
	token := jwt.New(jwt.SigningMethodHS256)

	// claimsのセット
	claims := token.Claims.(jwt.MapClaims)
	claims["admin"] = true
	claims["sub"] = "12345678901" // ユーザの一意識別子
	claims["name"] = "suna"
	claims["iat"] = time.Now()
	claims["exp"] = time.Now().Add(time.Hour * 24).Unix()
	// 電子署名
	tokenString, _ := token.SignedString([]byte("Dummy"))

	w.Write([]byte(tokenString))
}

var jwtMiddleware = jwtmiddleware.New(jwtmiddleware.Options{
	ValidationKeyGetter: func(token *jwt.Token) (interface{}, error) {
		return []byte("Dummy"), nil
	},
	SigningMethod: jwt.SigningMethodHS256,
})
