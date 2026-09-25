# 🍔 Biteflow — Full-Stack Swift Bistro & Food Ordering Platform

## Architecture

```mermaid
flowchart TB
    subgraph iOS["iOS App (Swift + UIKit)"]
        A[MenuViewController] --> B[FoodDetailViewController]
        A --> C[CartViewController]
        C --> D[OrderStatusViewController]
        P[BistroPortalViewController — Manager Tab]
        E[CartManager — Singleton Observer] --> C
        F[APIService — URLSession async/await] --> A
        F --> B
        F --> C
        F --> D
        F --> P
    end

    subgraph Backend["Backend (Swift Vapor)"]
        G[CategoryController]
        H[FoodItemController]
        I[OrderController]
        K[BistroController — Rush Throttle & Z-Report]
        J[(SQLite Database)]
        G --> J
        H --> J
        I --> J
        K --> J
    end

    F <-->|REST JSON / Codable| G
    F <-->|REST JSON / Codable| H
    F <-->|REST JSON / Codable| I
    F <-->|REST JSON / Codable| K
```

## Bistro Manager Features

1. **🍽️ Smart Dine-In Mode with QR Table Ordering & Tab Splitting**
   - Toggle between **Dine-In**, **Takeout**, and **Delivery**.
   - Table Number assignment (e.g. Table #4).
   - Live **Split the Bill** calculator (1 to 8 guests) with real-time per-person price calculation.
   - Zero delivery fee automatically applied for dine-in & pickup orders.

2. **⚡ Real-Time "86'd" (Item Sold Out) Instant Toggle & Low Stock Badges**
   - Manager can flick a switch to instantly 86 an item out of stock across all client devices.
   - Sold out items show an **"86'D · SOLD OUT"** overlay and disabled Add-to-Cart state.
   - Automatic low stock indicator: **"🔥 Only X left!"** badges when stock is 5 or fewer.

3. **⏱️ Kitchen Rush Hour Throttle & Dynamic Prep Times**
   - General manager can toggle **Peak Rush Mode** from the Manager Portal.
   - Customer menu immediately reflects an animated **"🔥 Kitchen Rush Active"** banner.
   - Prep times dynamically adjust by +15 minutes across all menu cards.

4. **🍷 Smart Upsell & Course Pairing Engine (Boosts AOV)**
   - Food detail screens feature a **"Chef's Recommended Pairing"** card (e.g., wine pairing, signature sides) with 1-tap addition to the order.
   - In-cart **"Complete Your Meal"** strip for quick 1-tap additions of desserts (Tiramisu) and beverages (Double Espresso).

5. **📊 Daily "Z-Report" & Shift Operations Dashboard**
   - Dedicated 4th tab: **Manager Portal**.
   - 4 Live KPI Cards: Gross Sales ($), Total Orders, Average Ticket Size ($), Active Kitchen Queue.
   - Live Shift Breakdown: Dine-in vs Takeout vs Delivery counts, Net Sales, Tax Collected.
   - **Top 5 Best-Selling Dishes** ranking by units sold and revenue generated.
   - Quick 86'd switcher table to manage menu availability in real-time.

---

## Project Structure

```text
Biteflow/
├── backend/                              # Swift Vapor REST API Server
│   ├── Package.swift                     # Dependencies: Vapor, Fluent, SQLite
│   ├── Sources/App/
│   │   ├── entrypoint.swift              # @main async entry
│   │   ├── configure.swift               # DB, CORS, migrations, server config
│   │   ├── routes.swift                  # /api/v1 route registration
│   │   ├── Models/
│   │   │   ├── Category.swift            # Fluent model
│   │   │   ├── FoodItem.swift            # Fluent model (86'd status, stockCount, pairing)
│   │   │   ├── Order.swift               # Fluent model (diningOption, tableNumber, splitCount)
│   │   │   └── OrderItem.swift           # Junction model (order ↔ food item)
│   │   ├── Controllers/
│   │   │   ├── CategoryController.swift  # GET categories, with-items
│   │   │   ├── FoodItemController.swift  # GET items, search, PATCH toggle-86, stock, upsells
│   │   │   ├── OrderController.swift     # POST/GET orders, auto-inventory decrement
│   │   │   └── BistroController.swift    # GET status, POST rush-mode, GET z-report
│   │   ├── Migrations/                   # Schema + rich seed data
│   │   └── DTOs/
│   │       ├── OrderDTO.swift            # Request/Response transfer objects
│   │       └── BistroDTO.swift           # Operational state, Z-Report, top dishes DTOs
│   └── Tests/AppTests/
│
└── iOS/                                  # Native Swift + UIKit iOS App
    └── BiteflowApp/
        ├── App/
        │   ├── AppDelegate.swift         # Global appearance config
        │   └── SceneDelegate.swift       # 4-tab setup (Menu, Cart, Orders, Manager)
        ├── Controllers/
        │   ├── MenuViewController.swift  # Grid feed, search, category pills, rush banner
        │   ├── FoodDetailViewController.swift # Hero image, pairing card, 86'd handling
        │   ├── CartViewController.swift  # Dine-in selector, bill splitter, upsell bar
        │   ├── OrderStatusViewController.swift # Real-time order tracking
        │   └── BistroPortalViewController.swift # Live Z-Report, Rush switch, 86 manager
        ├── Models/
        │   ├── Category.swift
        │   ├── FoodItem.swift
        │   ├── CartItem.swift
        │   ├── Order.swift
        │   └── BistroModels.swift
        ├── Views/
        │   ├── FoodCardCell.swift        # Card cell with 86'd badge & low stock pill
        │   ├── CartItemCell.swift
        │   └── CategoryPillCell.swift
        ├── Managers/
        │   └── CartManager.swift         # Observer pattern, dining mode, bill splitting
        ├── Networking/
        │   └── APIService.swift          # URLSession async/await client with PATCH
        ├── Extensions/
        │   └── UIView+Layout.swift       # AutoLayout DSL helpers
        └── Resources/
            ├── Theme.swift               # Design system & adaptive color tokens
            └── Info.plist
```

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/categories` | List all categories |
| `GET` | `/api/v1/categories/with-items` | Categories with nested food items |
| `GET` | `/api/v1/items` | All menu items with 86'd status |
| `GET` | `/api/v1/items/featured` | Top-rated items (rating ≥ 4.7) |
| `GET` | `/api/v1/items/search?q={query}` | Search by name or description |
| `GET` | `/api/v1/items/:id/upsells` | Recommended drinks/dessert pairings |
| `PATCH` | `/api/v1/items/:id/toggle-86` | Toggle 86'd / sold-out status |
| `PATCH` | `/api/v1/items/:id/stock` | Update stock count |
| `POST` | `/api/v1/orders` | Place order (dine-in/takeout/delivery) |
| `GET` | `/api/v1/orders` | List all orders |
| `GET` | `/api/v1/orders/:id` | Order details with items |
| `GET` | `/api/v1/bistro/status` | Kitchen rush status & active ticket count |
| `POST` | `/api/v1/bistro/rush-mode` | Manager peak rush mode toggle |
| `GET` | `/api/v1/bistro/z-report` | Daily Z-Report, gross sales, & top dishes |
