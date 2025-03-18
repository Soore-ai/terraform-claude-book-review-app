const ReviewModel = require("../models/Review");
const BookModel = require("../models/Book");

module.exports = (sequelize) => {
  const Review = ReviewModel(sequelize);
  const Book = BookModel(sequelize);

  return {
    addReview: async (req, res) => {
      try {
        const { bookId, comment, rating } = req.body;
        const userId = req.user.userId; // Extract userId from the authenticated request

        // Check if the book exists
        const book = await Book.findByPk(bookId);
        if (!book) {
          return res.status(404).json({ message: "Book not found" });
        }

        // Create a new review
        await Review.create({ userId, bookId, comment, rating });
        res.status(201).json({ message: "Review added successfully" });
      } catch (error) {
        res.status(500).json({ message: "Server error", error });
      }
    },

    getReviewsForBook: async (req, res) => {
      try {
        const { bookId } = req.params;

        // Fetch reviews for the specified book
        const reviews = await Review.findAll({ where: { bookId } });

        res.json(reviews);
      } catch (error) {
        res.status(500).json({ message: "Server error", error });
      }
    }
  };
};
