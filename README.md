## **Book Review App**

### **Overview**
The **Book Review App** is a two-tier web application that allows users to browse books, read reviews, and submit their own reviews. Users can register and log in to post reviews, while unauthenticated users can only view book details and existing reviews.

The application is structured into two separate components:
1. **Frontend:** A Next.js-based UI for users to browse and review books.
2. **Backend:** A Node.js and Express.js API that handles authentication, book management, and reviews.

![Two-tiered-Web-application-architecture](https://github.com/user-attachments/assets/f8253a9c-b019-4620-9c96-09e37a04897c)

This project is designed to demonstrate modern web application development with a clean separation between the frontend and backend, making it easy to deploy independently.

---

## **Features**
- **User Authentication**  
  - Register new users  
  - Login with email and password  
  - Secure authentication with JWT  

- **Book Management**  
  - View a list of books  
  - Fetch book details  
  - Admins can add new books (future enhancement)  

- **Review System**  
  - View reviews for a book  
  - Logged-in users can submit reviews  
  - Reviews include ratings, usernames, and timestamps  

- **State Management & API Integration**  
  - Frontend dynamically fetches data from the backend  
  - User authentication state is managed using React Context  

---

## **Technology Stack**
### **Frontend**
- **Next.js** (React framework for server-side rendering and routing)
- **Tailwind CSS** (for styling)
- **Axios** (for making API requests)
- **React Context API** (for global state management)

### **Backend**
- **Node.js & Express.js** (for API development)
- **MySQL & Sequelize** (for database management)
- **JWT (JSON Web Token)** (for authentication)
- **bcrypt.js** (for password hashing)
- **CORS** (for cross-origin request handling)

---

## **Application Structure**
The project is organized into two directories:

```
/book-review-app
 ├── /frontend   # Next.js frontend
 ├── /backend    # Node.js & Express backend
 ├── README.md   # Project overview
```

### **Frontend Structure**
```
/frontend
 ├── /src
 │   ├── /app
 │   │   ├── page.js       # Home page (list of books)
 │   │   ├── /book/[id]    # Dynamic route for book details
 │   │   ├── /login        # Login page
 │   │   ├── /register     # Register page
 │   ├── /components       # Reusable UI components (Navbar)
 │   ├── /context          # React Context for user authentication
 │   ├── /services         # API service functions (Axios)
 │   ├── /styles           # Global styles (Tailwind)
 ├── next.config.js        # Next.js configuration
 ├── package.json          # Frontend dependencies
 ├── README.md             # Frontend-specific documentation
```

### **Backend Structure**
```
/backend
 ├── /src
 │   ├── /config           # Database connection setup
 │   ├── /models           # Sequelize models (User, Book, Review)
 │   ├── /routes           # Express route handlers
 │   ├── /controllers      # Business logic for API endpoints
 │   ├── /middleware       # Authentication middleware (JWT)
 │   ├── /server.js        # Main Express server file
 ├── package.json          # Backend dependencies
 ├── README.md             # Backend-specific documentation
```

---

## **Setup Instructions**

It's available in respective folder. 


