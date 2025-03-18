const express = require("express");
require("dotenv").config();
const cors = require("cors");
const initializeDatabase = require("./config/db");

const app = express();
app.use(express.json());
app.use(cors());

async function startServer() {
  try {
    // Initialize database and get Sequelize instance
    const sequelize = await initializeDatabase();

    // Load models
    const User = require("./models/User")(sequelize);
    const Book = require("./models/Book")(sequelize);
    const Review = require("./models/Review")(sequelize);

    // Sync models (Creates tables if they don't exist)
    await sequelize.sync({ alter: true });
    console.log("Tables created!");

    // Insert sample books if table is empty
    const bookCount = await Book.count();
    if (bookCount === 0) {
      await Book.bulkCreate([
        { title: "The Pragmatic Programmer", author: "Andrew Hunt", rating: 4.8 },
        { title: "Clean Code", author: "Robert C. Martin", rating: 4.7 },
        { title: "JavaScript: The Good Parts", author: "Douglas Crockford", rating: 4.5 },
      ]);
      console.log("Sample books added!");
    }

    // Load routes (AFTER Sequelize is initialized)
    const userRoutes = require("./routes/userRoutes")(sequelize);
    const reviewRoutes = require("./routes/reviewRoutes")(sequelize);
    const bookRoutes = require("./routes/bookRoutes")(sequelize);

    // Register API routes
    app.use("/api/users", userRoutes);
    app.use("/api/reviews", reviewRoutes);
    app.use("/api/books", bookRoutes);

    // Health check endpoint
    app.get("/", (req, res) => {
      res.send("Book Review API is running...");
    });

    // Start the server
    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  } catch (error) {
    console.error("Server startup failed:", error);
  }
}

// Start the server
startServer();
