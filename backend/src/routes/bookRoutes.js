const express = require("express");
const router = express.Router();

module.exports = (sequelize) => {
  const bookController = require("../controllers/bookController")(sequelize);

  router.get("/", bookController.getAllBooks);
  router.post("/", bookController.addBook); // Can be restricted to admin
  router.get("/:id", bookController.getBookById);
  return router;
};
