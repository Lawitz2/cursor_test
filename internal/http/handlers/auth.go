package handlers

import (
	"log"
	"net/http"

	"BAD-example/internal/repository"
	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	userRepo *repository.UserRepository
}

func NewAuthHandler(userRepo *repository.UserRepository) *AuthHandler {
	return &AuthHandler{userRepo: userRepo}
}

// RequestCode обрабатывает POST /api/v1/auth/request-code
func (h *AuthHandler) RequestCode(c *gin.Context) {
	var input struct {
		Phone string `json:"phone" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "phone is required"})
		return
	}

	// Заглушка: имитируем отправку SMS, просто выводя код в лог сервера
	log.Printf("ОТПРАВКА SMS: Код 1234 для номера %s", input.Phone)

	c.JSON(http.StatusOK, gin.H{"message": "code sent"})
}

// VerifyCode обрабатывает POST /api/v1/auth/verify-code
func (h *AuthHandler) VerifyCode(c *gin.Context) {
	var input struct {
		Phone string `json:"phone" binding:"required"`
		Code  string `json:"code" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "phone and code are required"})
		return
	}

	// Проверка кода-заглушки (всегда 1234 для MVP)
	if input.Code != "1234" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid code"})
		return
	}

	// Создаем или получаем пользователя в БД по номеру телефона
	user, err := h.userRepo.UpsertByPhone(c.Request.Context(), input.Phone, "")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to process user"})
		return
	}

	// TODO: В следующем шаге добавим генерацию JWT токена или сессии
	c.JSON(http.StatusOK, gin.H{
		"message": "success",
		"user_id": user.ID,
	})
}
