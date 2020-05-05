Companies
  - They belong to users via CompanyTaggings
CompanyTaggings
  - Belongs to user
  - Belongs to company
  - Roles (privileges are passed downwards):
    - reader
      - Can look at every, can modify nothing
    - writer
      - Can look at everything and can modify projects and transactions
    - leader
      - can change privileges for writers and readers
      - can add people to the company
    - owner
      - can change privileges for leader
      - can transfer ownership
      - can delete company
clients
  - belongs_to company
  - column_names
    - name
    - kind (client/provider)

addresses
  - belong_to client
  - column_names
    - line one
    - line two
    - zip-code
    - city
    - state
    - country
transactions
  - column_names
    - amount
    - kind (payable, receivable, expense, revenue)
    - project_id (optional)
    - client_id (optional)
    - date