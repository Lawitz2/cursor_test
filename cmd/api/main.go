package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"BAD-example/internal/config"
	"BAD-example/internal/db"
	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Загружаем конфигурацию
	cfg := config.Load()

	// 2. Инициализация БД
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := db.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Критическая ошибка БД: %v", err)
	}
	defer pool.Close()

	// 3. Настраиваем режим Gin
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 4. Инициализируем роутер
	router := gin.Default()

	// Базовый эндпоинт для проверки (Health-check)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"db":     "connected",
			"env":    cfg.Env,
		})
	})

	// 5. Запуск сервера
	addr := fmt.Sprintf(":%s", cfg.Port)
	fmt.Printf("Сервер запущен на %s в режиме %s\n", addr, cfg.Env)
	if err := router.Run(addr); err != nil {
		log.Fatalf("Ошибка при запуске сервера: %v", err)
	}
}
