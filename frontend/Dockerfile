# Gunakan image resmi Node.js versi stabil
FROM node:18

# Set direktori kerja di dalam container
WORKDIR /app

# Salin file dependency terlebih dahulu
COPY package.json package-lock.json ./

# Install semua dependency termasuk react-scripts dan tampilkan hasilnya
RUN npm install && \
    echo "📦 Installed node_modules:" && \
    ls node_modules && \
    echo "🔍 Checking react-scripts:" && \
    ls node_modules/react-scripts

# Salin seluruh kode aplikasi frontend
COPY . .

# Buka port 3000 untuk akses React
EXPOSE 3000

# Jalankan aplikasi React
CMD ["npm", "start"]
