-- name: GetUserByPhone :one
SELECT * FROM users
WHERE phone = $1 LIMIT 1;

-- name: GetUserById :one
SELECT * FROM users
WHERE id = $1 LIMIT 1;

-- name: UpsertUser :one
INSERT INTO users (
    phone, full_name, updated_at
) VALUES (
             $1, $2, now()
         )
    ON CONFLICT (phone) DO UPDATE SET
    full_name = EXCLUDED.full_name,
                               updated_at = now()
                               RETURNING *;
