package handlers

import (
	"crypto/rand"
	"fmt"
	"net/http"

	"BAD-example/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"
)

const guestTokenCookie = "guest_token"

type CartHandler struct {
	repo *repository.CartRepository
}

func NewCartHandler(repo *repository.CartRepository) *CartHandler {
	return &CartHandler{repo: repo}
}

// getOrSetGuestToken извлекает токен из куки или создает новый
func (h *CartHandler) getOrSetGuestToken(c *gin.Context) string {
	token, err := c.Cookie(guestTokenCookie)
	if err != nil || token == "" {
		// Генерируем простой случайный токен
		b := make([]byte, 16)
		rand.Read(b)
		token = fmt.Sprintf("%x", b)

		// Устанавливаем куку на 30 дней
		c.SetCookie(guestTokenCookie, token, 3600*24*30, "/", "", false, true)
	}
	return token
}

// --- API Handlers ---

// AddToCart обрабатывает POST /api/v1/cart/items
func (h *CartHandler) AddToCart(c *gin.Context) {
	var input struct {
		ProductID string `json:"product_id" binding:"required"`
		Qty       int32  `json:"qty" binding:"required,min=1"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	guestToken := h.getOrSetGuestToken(c)
	cart, err := h.repo.GetOrCreateCart(c.Request.Context(), guestToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get cart"})
		return
	}

	var pID pgtype.UUID
	if err := pID.UnmarshalJSON([]byte(input.ProductID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid product_id"})
		return
	}

	if err := h.repo.AddItem(c.Request.Context(), cart.ID, pID, input.Qty); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to add item"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "item added to cart"})
}

// GetCart обрабатывает GET /api/v1/cart
func (h *CartHandler) GetCart(c *gin.Context) {
	guestToken := h.getOrSetGuestToken(c)
	cart, err := h.repo.GetOrCreateCart(c.Request.Context(), guestToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get cart"})
		return
	}

	items, err := h.repo.GetItems(c.Request.Context(), cart.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch items"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"cart_id": cart.ID,
		"items":   items,
	})
}

// UpdateItem обрабатывает PATCH /api/v1/cart/items/:product_id
func (h *CartHandler) UpdateItem(c *gin.Context) {
	productIDStr := c.Param("product_id")
	var input struct {
		Qty int32 `json:"qty" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	guestToken := h.getOrSetGuestToken(c)
	cart, err := h.repo.GetOrCreateCart(c.Request.Context(), guestToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get cart"})
		return
	}

	var pID pgtype.UUID
	if err := pID.UnmarshalJSON([]byte(productIDStr)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid product_id"})
		return
	}

	if err := h.repo.UpdateQty(c.Request.Context(), cart.ID, pID, input.Qty); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update quantity"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "cart updated"})
}

// RemoveItem обрабатывает DELETE /api/v1/cart/items/:product_id
func (h *CartHandler) RemoveItem(c *gin.Context) {
	productIDStr := c.Param("product_id")
	guestToken := h.getOrSetGuestToken(c)
	cart, err := h.repo.GetOrCreateCart(c.Request.Context(), guestToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get cart"})
		return
	}

	var pID pgtype.UUID
	if err := pID.UnmarshalJSON([]byte(productIDStr)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid product_id"})
		return
	}

	if err := h.repo.RemoveItem(c.Request.Context(), cart.ID, pID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to remove item"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "item removed"})
}

// --- HTML Handlers (SSR) ---

// CartView отображает страницу корзины
func (h *CartHandler) CartView(c *gin.Context) {
	guestToken := h.getOrSetGuestToken(c)
	cart, err := h.repo.GetOrCreateCart(c.Request.Context(), guestToken)
	if err != nil {
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}

	items, err := h.repo.GetItems(c.Request.Context(), cart.ID)
	if err != nil {
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}

	c.HTML(http.StatusOK, "cart.tmpl", gin.H{
		"items": items,
	})
}
