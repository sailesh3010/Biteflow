import Fluent

/// Seeds the database with sample Bistro menu data and initial orders for Z-Report demo
struct SeedData: AsyncMigration {
    func prepare(on database: Database) async throws {
        // MARK: - Categories
        let burgers = Category(name: "Burgers", icon: "🍔", sortOrder: 0)
        let pizzas  = Category(name: "Pizzas", icon: "🍕", sortOrder: 1)
        let salads  = Category(name: "Salads", icon: "🥗", sortOrder: 2)
        let pasta   = Category(name: "Pasta", icon: "🍝", sortOrder: 3)
        let desserts = Category(name: "Desserts", icon: "🍰", sortOrder: 4)
        let drinks  = Category(name: "Drinks", icon: "🥤", sortOrder: 5)
        
        let categories = [burgers, pizzas, salads, pasta, desserts, drinks]
        for cat in categories {
            try await cat.save(on: database)
        }
        
        // MARK: - Burgers
        let burgerItems: [(String, String, Double, Int, Int, Bool, Bool, Double, Bool, Int?, String?, Double?)] = [
            ("Classic Smash Burger",
             "Double-stacked hand-smashed beef patties with melted American cheese, caramelized onions, pickles, and secret sauce on a toasted brioche bun.",
             12.99, 680, 15, false, false, 4.8, true, nil, "Truffle Parmesan Fries", 5.99),
            ("Truffle Mushroom Burger",
             "Angus beef patty topped with sautéed wild mushrooms, Swiss cheese, truffle aioli, and arugula on a pretzel bun.",
             16.99, 720, 18, false, false, 4.9, true, 4, "Napa Valley Pinot Noir (Glass)", 11.99),
            ("Spicy Jalapeño Crunch",
             "Crispy fried chicken breast with pepper jack cheese, pickled jalapeños, sriracha mayo, and crunchy slaw.",
             14.49, 650, 14, false, true, 4.6, true, nil, "Craft IPA Draft", 6.99),
            ("Beyond Garden Burger",
             "Plant-based patty with avocado, roasted tomatoes, vegan chipotle sauce, and mixed greens on a whole wheat bun.",
             15.99, 480, 12, true, false, 4.5, true, 2, "Fresh Lemonade", 4.99),
        ]
        
        for item in burgerItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                isAvailable: item.8, stockCount: item.9,
                pairingName: item.10, pairingPrice: item.11,
                rating: item.7, categoryID: burgers.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Pizzas
        let pizzaItems: [(String, String, Double, Int, Int, Bool, Bool, Double, Bool, Int?, String?, Double?)] = [
            ("Margherita Classica",
             "San Marzano tomato sauce, fresh mozzarella di bufala, basil, and extra virgin olive oil on a wood-fired thin crust.",
             13.99, 540, 20, true, false, 4.9, true, nil, "Chianti Classico (Glass)", 10.99),
            ("Pepperoni Inferno",
             "Spicy pepperoni, mozzarella, chili flakes, and honey drizzle on our signature sourdough crust.",
             15.49, 620, 20, false, true, 4.7, true, 5, "Cold Peroni Lager", 6.49),
            ("BBQ Chicken Ranch",
             "Grilled chicken, smoky BBQ sauce, red onions, cilantro, and ranch drizzle on a thick crust.",
             16.99, 710, 22, false, false, 4.6, true, nil, "Garlic Herb Breadsticks", 4.99),
            ("Four Cheese Truffle",
             "Mozzarella, gorgonzola, fontina, and parmesan with truffle oil and fresh thyme.",
             18.49, 680, 20, true, false, 4.8, false, 0, "Prosecco Brut (Glass)", 12.00), // 86'd out of stock
        ]
        
        for item in pizzaItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                isAvailable: item.8, stockCount: item.9,
                pairingName: item.10, pairingPrice: item.11,
                rating: item.7, categoryID: pizzas.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Salads
        let saladItems: [(String, String, Double, Int, Int, Bool, Bool, Double, Bool, Int?, String?, Double?)] = [
            ("Caesar Supreme",
             "Crisp romaine, shaved parmesan, garlic herb croutons, and house-made creamy Caesar dressing.",
             11.99, 380, 10, false, false, 4.7, true, nil, "Grilled Chicken Skewer", 4.50),
            ("Mediterranean Quinoa",
             "Baby spinach, quinoa, kalamata olives, feta, cucumbers, cherry tomatoes, and lemon-oregano vinaigrette.",
             13.49, 420, 10, true, false, 4.6, true, 3, "House Sparkling Water", 3.50),
            ("Burrata & Peach Caprese",
             "Fresh burrata ball, grilled ripe peaches, heirloom tomatoes, basil, and balsamic reduction glaze.",
             14.99, 450, 12, true, false, 4.9, true, nil, "Sauvignon Blanc", 11.00),
        ]
        
        for item in saladItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                isAvailable: item.8, stockCount: item.9,
                pairingName: item.10, pairingPrice: item.11,
                rating: item.7, categoryID: salads.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Pasta
        let pastaItems: [(String, String, Double, Int, Int, Bool, Bool, Double, Bool, Int?, String?, Double?)] = [
            ("Truffle Tagliatelle",
             "Fresh egg pasta tossed in a creamy black truffle butter sauce with shaved summer truffles and parmigiano.",
             19.99, 780, 18, true, false, 4.9, true, nil, "Barolo DOCG (Glass)", 14.50),
            ("Spicy Penne Arrabbiata",
             "Penne pasta in fiery San Marzano tomato sauce with garlic, chili peppers, and fresh Italian parsley.",
             14.99, 520, 15, true, true, 4.5, true, nil, "Fresh Burrata Topping", 4.00),
            ("Lobster & Crab Ravioli",
             "Handmade ravioli filled with Maine lobster and lump crab, served in a rich saffron cream bisque.",
             22.99, 690, 22, false, false, 4.8, true, 3, "Chardonnay Reserve", 13.00),
        ]
        
        for item in pastaItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                isAvailable: item.8, stockCount: item.9,
                pairingName: item.10, pairingPrice: item.11,
                rating: item.7, categoryID: pasta.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Desserts
        let dessertItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Tiramisu Tradizionale",
             "Espresso-soaked ladyfingers layered with mascarpone cream, dusted with dark Valrhona cocoa powder.",
             9.49, 420, 5, true, false, 4.9),
            ("Molten Chocolate Lava Cake",
             "Warm chocolate cake with a liquid fudge center, served with vanilla bean gelato.",
             10.99, 580, 8, true, false, 4.8),
            ("New York Cheesecake",
             "Classic creamy cheesecake on a graham cracker crust with seasonal berry compote.",
             8.99, 380, 5, true, false, 4.7),
        ]
        
        for item in dessertItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                isAvailable: true, stockCount: nil,
                pairingName: "Double Espresso", pairingPrice: 3.50,
                rating: item.7, categoryID: desserts.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Drinks
        let drinkItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Fresh Mango Smoothie",
             "Blended Alphonso mango, banana, Greek yogurt, and a touch of honey.",
             6.99, 220, 5, true, false, 4.8),
            ("Iced Caramel Latte",
             "Double-shot espresso with caramel syrup, cold milk, and ice, topped with whipped cream.",
             5.49, 180, 3, true, false, 4.6),
            ("Classic Lemonade",
             "Freshly squeezed lemons with cane sugar, mint sprigs, and sparkling water.",
             4.99, 120, 3, true, false, 4.4),
        ]
        
        for item in drinkItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                isAvailable: true, stockCount: nil,
                pairingName: nil, pairingPrice: nil,
                rating: item.7, categoryID: drinks.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Initial Sample Orders (for instant Manager Z-Report data)
        let sampleOrder1 = Order(
            customerName: "Alex Vance",
            customerPhone: "555-0199",
            deliveryAddress: "Dine-In",
            subtotal: 44.97,
            tax: 3.60,
            deliveryFee: 0.0,
            total: 48.57,
            specialInstructions: "Table 7 · Patio seating",
            diningOption: "dine_in",
            tableNumber: "Table 7",
            splitCount: 3,
            status: .confirmed
        )
        try await sampleOrder1.save(on: database)
        
        let sampleOrder2 = Order(
            customerName: "Sophia Miller",
            customerPhone: "555-0288",
            deliveryAddress: "Dine-In",
            subtotal: 62.46,
            tax: 5.00,
            deliveryFee: 0.0,
            total: 67.46,
            specialInstructions: "Table 12 · Window booth",
            diningOption: "dine_in",
            tableNumber: "Table 12",
            splitCount: 2,
            status: .preparing
        )
        try await sampleOrder2.save(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await OrderItem.query(on: database).delete()
        try await Order.query(on: database).delete()
        try await FoodItem.query(on: database).delete()
        try await Category.query(on: database).delete()
    }
}
