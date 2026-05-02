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
