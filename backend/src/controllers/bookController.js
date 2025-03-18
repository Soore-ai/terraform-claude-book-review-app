const BookModel = require("../models/Book");

module.exports = (sequelize) => {
  const Book = BookModel(sequelize);

  return {
    getAllBooks: async (req, res) => {
      try {
        const books = await Book.findAll();
        res.json(books);
      } catch (error) {
        res.status(500).json({ message: "Server error", error });
      }
    },

    getBookById: async (req, res) => {
      try {
        const { id } = req.params;
        const book = await Book.findByPk(id);
        if (!book) {
          return res.status(404).json({ message: "Book not found" });
        }
        res.json(book);
      } catch (error) {
        res.status(500).json({ message: "Server error", error });
      }
    },    

    addBook: async (req, res) => {
      try {
        const { title, author, rating } = req.body;

        // Check if book already exists
        const existingBook = await Book.findOne({ where: { title, author } });
        if (existingBook) {
          return res.status(400).json({ message: "Book already exists" });
        }

        // Create a new book
        const newBook = await Book.create({ title, author, rating });
        res.status(201).json({ message: "Book added successfully", book: newBook });
      } catch (error) {
        res.status(500).json({ message: "Server error", error });
      }
    }
  };
};
