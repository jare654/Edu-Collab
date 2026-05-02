# Database Schema Documentation

> **Notice:** The schema is currently in a state of rapid evolution.
> Migrations may be non-destructive but are not guaranteed during Beta.

## Tables
### Users
- id: uuid
- email: text
- display_name: text

### Projects
- id: uuid
- title: text
- owner_id: uuid (FK)

## Relationships
- Users have many Projects
- Projects have many Resources
