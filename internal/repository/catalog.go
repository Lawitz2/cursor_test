package repository

import (
	"context"

	"BAD-example/internal/db/sqlc"
	"github.com/jackc/pgx/v5/pgtype"
)

type CatalogRepository struct {
	q *db.Queries
}

func NewCatalogRepository(q *db.Queries) *CatalogRepository {
	return &CatalogRepository{q: q}
}

// Categories
func (r *CatalogRepository) ListCategories(ctx context.Context) ([]db.Category, error) {
	return r.q.ListCategories(ctx)
}

func (r *CatalogRepository) GetCategoryBySlug(ctx context.Context, slug string) (db.Category,
	error) {
	return r.q.GetCategoryBySlug(ctx, slug)
}

// Products
func (r *CatalogRepository) ListProducts(ctx context.Context) ([]db.ListProductsRow, error) {
	return r.q.ListProducts(ctx)
}

func (r *CatalogRepository) ListProductsByCategory(ctx context.Context, categoryID pgtype.UUID) ([]db.ListProductsByCategoryRow, error) {
	return r.q.ListProductsByCategory(ctx, categoryID)
}

func (r *CatalogRepository) GetProductBySlug(ctx context.Context, slug string) (db.GetProductBySlugRow, error) {
	return r.q.GetProductBySlug(ctx, slug)
}
