const { Sequelize } = require("sequelize");
require("dotenv").config();

const sequelize = new Sequelize("", process.env.DB_USER, process.env.DB_PASS, {
  host: process.env.DB_HOST,
  dialect: "mysql",
  logging: false,
});

async function initializeDatabase() {
  try {
    await sequelize.query(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME};`);
    console.log(`Database '${process.env.DB_NAME}' is ready!`);
    
    sequelize.close(); // Close this connection and reinitialize with DB name
    
    const sequelizeWithDB = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
      host: process.env.DB_HOST,
      dialect: "mysql",
      logging: false,
    });

    return sequelizeWithDB;
  } catch (error) {
    console.error("Database initialization failed:", error);
    process.exit(1);
  }
}

module.exports = initializeDatabase;
