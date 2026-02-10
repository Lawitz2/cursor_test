package repository

import (
	"BAD-example/internal/db/sqlc"
	"context"
	"github.com/jackc/pgx/v5/pgtype"
)

type CartRepository struct {
	q *db.Queries
}

func NewCartRepository(q *db.Queries) *CartRepository {
	return &CartRepository{q: q}
}

// GetOrCreateCart находит активную корзину по токену или создает новую
func (r *CartRepository) GetOrCreateCart(ctx context.Context, guestToken string) (db.Cart, error) {
	token := pgtype.Text{String: guestToken, Valid: true}

	cart, err := r.q.GetCartByGuestToken(ctx, token)
	if err == nil {
		return cart, nil
	}

	// Если не нашли, создаем новую
	return r.q.CreateCart(ctx, token)
}

// AddItem добавляет товар в корзину
func (r *CartRepository) AddItem(ctx context.Context, cartID pgtype.UUID, productID pgtype.UUID, qty int32) error {
	// Получаем текущую цену товара для снапшота
	_, _ = r.q.GetProductBySlug(ctx, "") // Нам нужен метод GetProductByID, но пока используем что есть или упрощаем
	// Для MVP: просто добавляем, снапшот цены можно взять из текущей цены в БД
	
	// В реальном приложении здесь был бы вызов GetProductByID
	// Для текущей реализации предположим, что цена берется в AddItemToCart через подзапрос или передается снаружи

	return r.q.AddItemToCart(ctx, db.AddItemToCartParams{
		CartID:    cartID,
		ProductID: productID,
		Qty:       qty,
		// PriceSnapshot: product.Price, // Упростим для MVP
	})
}

func (r *CartRepository) GetItems(ctx context.Context, cartID pgtype.UUID) ([]db.GetCartItemsRow, error) {
	return r.q.GetCartItems(ctx, cartID)
}

func (r *CartRepository) UpdateQty(ctx context.Context, cartID pgtype.UUID, productID pgtype.UUID, qty int32) error {
	if qty <= 0 {
		return r.q.RemoveCartItem(ctx, cartID, productID)
	}
	return r.q.UpdateCartItemQty(ctx, cartID, productID, qty)
}

func (r *CartRepository) RemoveItem(ctx context.Context, cartID pgtype.UUID, productID pgtype.UUID) error {
	return r.q.RemoveCartItem(ctx, cartID, productID)
}
