package main

import (
	"fmt"
	"log"
	"net/http"

	"BAD-example/internal/config"
	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Загружаем конфигурацию
	cfg := config.Load()

	// 2. Настраиваем режим Gin
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 3. Инициализируем роутер
	router := gin.Default()

	// Базовый эндпоинт для проверки (Health-check)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"env":    cfg.Env,
		})
	})

	// 4. Запуск сервера
	addr := fmt.Sprintf(":%s", cfg.Port)
	fmt.Printf("Сервер запущен на %s в режиме %s\n", addr, cfg.Env)
	if err := router.Run(addr); err != nil {
		log.Fatalf("Ошибка при запуске сервера: %v", err)
	}
}
