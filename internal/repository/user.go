package repository

import (
	"BAD-example/internal/db/sqlc"
	"context"
	"github.com/jackc/pgx/v5/pgtype"
)

type UserRepository struct {
	q *db.Queries
}

func NewUserRepository(q *db.Queries) *UserRepository {
	return &UserRepository{q: q}
}

// GetByPhone находит пользователя по номеру телефона
func (r *UserRepository) GetByPhone(ctx context.Context, phone string) (db.User, error) {
	return r.q.GetUserByPhone(ctx, pgtype.Text{String: phone, Valid: true})
}

// UpsertByPhone создает или обновляет пользователя по номеру телефона
func (r *UserRepository) UpsertByPhone(ctx context.Context, phone string, fullName string) (db.User, error) {
	return r.q.UpsertUser(ctx, db.UpsertUserParams{
		Phone:    pgtype.Text{String: phone, Valid: true},
		FullName: fullName,
	})
}
