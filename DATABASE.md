# Database Schema Documentation

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
