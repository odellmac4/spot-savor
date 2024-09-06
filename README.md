# SpotSavor 🍴

Welcome to SpotSavor, where tradition meets innovation. Revolutionize how your restaurant handles reservations with our cutting-edge platform designed to streamline your workflow and enhance your guest experience. Say goodbye to paper logs and hello to seamless digital management—create, edit, update, and delete reservations with just a few clicks.

Empower your team with real-time updates and intuitive controls, making hosting and reservation management more efficient than ever. Whether you're booking a table for two or a party of twenty, SpotSavor ensures that every reservation is handled with precision and ease. Elevate your restaurant's operations and delight your guests with effortless reservation management. Embrace the future of dining with SpotSavor, where efficiency meets excellence.

## Getting Started
- Ruby (version >= 3.2.2)
- Rails (version >= 7.1.3.2)
- PostgreSQL
### Installation
1. `git clone`
2. `bundle install`
3. `rails db:create` `rails db:seed`
### Usage
Start the server with:
`rails server`

# Database Schema
```
create_table "reservations", force: :cascade do |t|
    t.string "name"
    t.integer "party_count"
    t.datetime "start_time"
    t.bigint "table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["table_id"], name: "index_reservations_on_table_id"
  end

  create_table "tables", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "reservations", "tables"
end
```


## <p align="center">Features</p>
