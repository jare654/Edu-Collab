# Database Schema Documentation

> **Notice:** The schema is currently in a state of rapid evolution.
> Migrations may be non-destructive but are not guaranteed during Beta.

## Tables
### Users
- `id`: uuid (Primary Key)
- `email`: text (Unique)
- `display_name`: text (Nullable)
- `created_at`: timestamp (Auto-generated) [Beta-Draft]

### Projects
- id: uuid
- title: text
- owner_id: uuid (FK)

## Relationships
- Users have many Projects
- Projects have many Resources
