package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"BAD-example/internal/config"
	"BAD-example/internal/db"
	db_sqlc "BAD-example/internal/db/sqlc"
	"BAD-example/internal/http/handlers"
	"BAD-example/internal/repository"
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

	// 3. Инициализация репозиториев и хендлеров
	queries := db_sqlc.New(pool)
	catalogRepo := repository.NewCatalogRepository(queries)
	catalogHandler := handlers.NewCatalogHandler(catalogRepo)

	// 4. Настраиваем режим Gin
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 5. Инициализируем роутер
	router := gin.Default()

	// Загрузка HTML шаблонов
	router.LoadHTMLGlob("internal/templates/public/*.tmpl")

	// Базовый эндпоинт для проверки (Health-check)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"db":     "connected",
			"env":    cfg.Env,
		})
	})

	// --- Публичные страницы (SSR) ---
	router.GET("/", catalogHandler.Index)
	router.GET("/products/:slug", catalogHandler.ProductDetail)

	// --- API v1 ---
	v1 := router.Group("/api/v1")
	{
		v1.GET("/categories", catalogHandler.ListCategories)
		v1.GET("/products", catalogHandler.ListProducts)
		v1.GET("/products/:slug", catalogHandler.GetProduct)
	}

	// 6. Запуск сервера
	addr := fmt.Sprintf(":%s", cfg.Port)
	fmt.Printf("Сервер запущен на %s в режиме %s\n", addr, cfg.Env)
	if err := router.Run(addr); err != nil {
		log.Fatalf("Ошибка при запуске сервера: %v", err)
	}
}
