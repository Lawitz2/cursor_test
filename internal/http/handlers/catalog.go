package handlers

import (
	"net/http"

	"BAD-example/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"
)

type CatalogHandler struct {
	repo *repository.CatalogRepository
}

func NewCatalogHandler(repo *repository.CatalogRepository) *CatalogHandler {
	return &CatalogHandler{repo: repo}
}

// --- API Handlers ---

func (h *CatalogHandler) ListCategories(c *gin.Context) {
	categories, err := h.repo.ListCategories(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch categories"})
		return
	}
	c.JSON(http.StatusOK, categories)
}

func (h *CatalogHandler) ListProducts(c *gin.Context) {
	categoryIDStr := c.Query("category_id")

	if categoryIDStr != "" {
		var categoryID pgtype.UUID
		if err := categoryID.Scan(categoryIDStr); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid category_id"})
			return
		}
		products, err := h.repo.ListProductsByCategory(c.Request.Context(), categoryID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch products by category"})
			return
		}
		c.JSON(http.StatusOK, products)
		return
	}

	products, err := h.repo.ListProducts(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch products"})
		return
	}
	c.JSON(http.StatusOK, products)
}

func (h *CatalogHandler) GetProduct(c *gin.Context) {
	slug := c.Param("slug")
	product, err := h.repo.GetProductBySlug(c.Request.Context(), slug)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "product not found"})
		return
	}
	c.JSON(http.StatusOK, product)
}

// --- HTML Handlers (SSR) ---

// Index отображает главную страницу со списком товаров
func (h *CatalogHandler) Index(c *gin.Context) {
	ctx := c.Request.Context()

	categories, err := h.repo.ListCategories(ctx)
	if err != nil {
		c.String(http.StatusInternalServerError, "Internal Server Error")
		return
	}

	var products interface{}
	categoryIDStr := c.Query("category_id")
	if categoryIDStr != "" {
		var categoryID pgtype.UUID
		if err := categoryID.Scan(categoryIDStr); err == nil {
			products, _ = h.repo.ListProductsByCategory(ctx, categoryID)
		}
	}

	if products == nil {
		products, _ = h.repo.ListProducts(ctx)
	}

	c.HTML(http.StatusOK, "index.tmpl", gin.H{
		"categories": categories,
		"products":   products,
	})
}

// ProductDetail отображает страницу товара
func (h *CatalogHandler) ProductDetail(c *gin.Context) {
	slug := c.Param("slug")
	product, err := h.repo.GetProductBySlug(c.Request.Context(), slug)
	if err != nil {
		c.String(http.StatusNotFound, "Product not found")
		return
	}

	c.HTML(http.StatusOK, "product.tmpl", gin.H{
		"product": product,
	})
}
