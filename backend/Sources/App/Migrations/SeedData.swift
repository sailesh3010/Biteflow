import Fluent

/// Seeds the database with sample Bistro menu data
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
        let burgerItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Classic Smash Burger",
             "Double-stacked hand-smashed beef patties with melted American cheese, caramelized onions, pickles, and secret sauce on a toasted brioche bun.",
             12.99, 680, 15, false, false, 4.8),
            ("Truffle Mushroom Burger",
             "Angus beef patty topped with sautéed wild mushrooms, Swiss cheese, truffle aioli, and arugula on a pretzel bun.",
             16.99, 720, 18, false, false, 4.9),
            ("Spicy Jalapeño Crunch",
             "Crispy fried chicken breast with pepper jack cheese, pickled jalapeños, sriracha mayo, and crunchy slaw.",
             14.49, 650, 14, false, true, 4.6),
            ("Beyond Garden Burger",
             "Plant-based patty with avocado, roasted tomatoes, vegan chipotle sauce, and mixed greens on a whole wheat bun.",
             15.99, 480, 12, true, false, 4.5),
        ]
        
        for item in burgerItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                rating: item.7, categoryID: burgers.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Pizzas
        let pizzaItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Margherita Classica",
             "San Marzano tomato sauce, fresh mozzarella di bufala, basil, and extra virgin olive oil on a wood-fired thin crust.",
             13.99, 540, 20, true, false, 4.9),
            ("Pepperoni Inferno",
             "Spicy pepperoni, mozzarella, chili flakes, and honey drizzle on our signature sourdough crust.",
             15.49, 620, 20, false, true, 4.7),
            ("BBQ Chicken Ranch",
             "Grilled chicken, smoky BBQ sauce, red onions, cilantro, and ranch drizzle on a thick crust.",
             16.99, 710, 22, false, false, 4.6),
            ("Four Cheese Truffle",
             "Mozzarella, gorgonzola, fontina, and parmesan with truffle oil and fresh thyme.",
             18.49, 680, 20, true, false, 4.8),
        ]
        
        for item in pizzaItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                rating: item.7, categoryID: pizzas.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Salads
        let saladItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Caesar Supreme",
             "Crisp romaine hearts, shaved parmesan, garlic croutons, and house-made Caesar dressing with grilled chicken.",
             11.99, 380, 8, false, false, 4.5),
            ("Mediterranean Bowl",
             "Quinoa, cherry tomatoes, cucumbers, kalamata olives, feta cheese, and lemon herb vinaigrette.",
             12.49, 320, 8, true, false, 4.7),
        ]
        
        for item in saladItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                rating: item.7, categoryID: salads.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Pasta
        let pastaItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Creamy Carbonara",
             "Spaghetti tossed with crispy pancetta, egg yolk, pecorino romano, and cracked black pepper.",
             14.99, 620, 18, false, false, 4.8),
            ("Spicy Arrabbiata Penne",
             "Penne in a fiery tomato sauce with garlic, red chili, fresh basil, and shaved parmesan.",
             12.99, 480, 15, true, true, 4.6),
        ]
        
        for item in pastaItems {
            let food = FoodItem(
                name: item.0, description: item.1, price: item.2,
                imageURL: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400",
                calories: item.3, prepTimeMinutes: item.4,
                isVegetarian: item.5, isSpicy: item.6,
                rating: item.7, categoryID: pasta.id!
            )
            try await food.save(on: database)
        }
        
        // MARK: - Desserts
        let dessertItems: [(String, String, Double, Int, Int, Bool, Bool, Double)] = [
            ("Molten Lava Cake",
             "Rich dark chocolate cake with a warm, gooey center, served with vanilla bean ice cream and fresh berries.",
             9.99, 450, 12, true, false, 4.9),
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
                rating: item.7, categoryID: drinks.id!
            )
            try await food.save(on: database)
        }
    }
    
    func revert(on database: Database) async throws {
        try await FoodItem.query(on: database).delete()
        try await Category.query(on: database).delete()
    }
}
