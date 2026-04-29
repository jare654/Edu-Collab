# Supabase Policies + CORS Notes

Apply the SQL policies in:

```
supabase_policies.sql
```

Apply the schema alignment in:

```
supabase_schema.sql
```

## Role Claim
Lecturer-only policies rely on `auth.jwt() -> 'user_metadata' ->> 'role' = 'lecturer'`.
Set this value in your auth pipeline (e.g., via `user_metadata.role` or a custom JWT claim).

## CORS
Supabase Storage CORS is configured in the Supabase dashboard (Storage > Settings).
Add your app origins (e.g., `http://localhost:3000`, `https://yourdomain.com`) as needed.
