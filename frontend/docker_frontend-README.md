### **Dockerizing the Frontend (Next.js App)**

Now that the backend is running inside Docker, let's **Dockerize the frontend**.

---

## **Step 1: Create `Dockerfile` for Frontend**
Inside the **frontend** folder, create a file named **`Dockerfile`**:
```sh
cd ~/book-review-app/frontend
touch Dockerfile
nano Dockerfile
```

### **Dockerfile Content**
```Dockerfile
# Use Node.js as the base image for building
FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the Next.js application
RUN npm run build

# Use a minimal Node.js runtime for serving the Next.js app
FROM node:18 AS runner

# Set working directory inside the container
WORKDIR /app

# Copy the built Next.js files
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Set environment variable for production
ENV NODE_ENV=production
ENV PORT=3000

# Expose the application port
EXPOSE 3000

# Start the Next.js server
CMD ["npm", "run", "start"]
```

---

## **Step 2: Create `nginx.conf` for Reverse Proxy** 

**(NOT TESTED)**

To serve the Next.js app properly, create an **`nginx.conf`** file:
```sh
nano nginx.conf
```

### **nginx.conf Content**
```nginx
server {
    listen 80;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://backend-container:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    error_page 404 /index.html;
}
```

---

## **Step 3: Create `.dockerignore`**
To **optimize the build process**, create a `.dockerignore` file:
```sh
nano .dockerignore
```

### **Content of `.dockerignore`**
```
node_modules
.next
out
npm-debug.log
.DS_Store
.env
```

---

## **Step 4: Build the Frontend Image**
Run the following command to **build the frontend image**:
```sh
docker build -t book-review-frontend .
```

Verify the image was created:
```sh
docker images
```
Expected output:
```
REPOSITORY             TAG       IMAGE ID       CREATED        SIZE
book-review-frontend   latest    xxxxxxxxxxxx   xx seconds ago   150MB
```

---

## **Step 5: Run Frontend Container**
Now, run the frontend container:
```sh
docker run -d \
  --name frontend-container \
  -p 3000:3000 \
  --network host \
  book-review-frontend
```

### **Explanation**
- `-d`: Runs the container in **detached mode**.
- `--name frontend-container`: Names the container.
- `-p 80:80`: Maps port **80** inside Docker to **80** on the host.
- `--network host`: Uses **host network**.

---

## **Step 6: Verify Frontend is Running**
Check running containers:
```sh
docker ps
```
You should see:
```
CONTAINER ID   IMAGE                 PORTS                    NAMES
xxxxxxxxxxxx   book-review-frontend   0.0.0.0:80->80/tcp       frontend-container
```

Check logs:
```sh
docker logs frontend-container
```

---

## **Step 7: Test the Application**
Now, open your browser and go to:
```
http://<YOUR_SERVER_PUBLIC_IP>
```

### **Test Backend API from Frontend**
If the backend is running on `http://<YOUR_SERVER_PUBLIC_IP>:3001`, update the `.env` file:
```sh
nano .env.local
```
Set the **API URL**:
```
NEXT_PUBLIC_API_URL=http://<YOUR_SERVER_PUBLIC_IP>:3001
```

Then restart the frontend container:
```sh
docker stop frontend-container
docker rm frontend-container
docker run -d \
  --name frontend-container \
  -p 80:80 \
  --network host \
  book-review-frontend
```

---

## **Step 8: Restart & Stop Containers**
To restart the frontend:
```sh
docker restart frontend-container
```

To stop the frontend:
```sh
docker stop frontend-container
```

To remove the frontend container:
```sh
docker rm frontend-container
```

