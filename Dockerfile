# ---------- Stage 1: Build React ----------
FROM node:20-alpine AS client-build
WORKDIR /app

# ก๊อปปี้ไฟล์ทั้งหมด (รวมถึงโฟลเดอร์ client และ server)
COPY . .

# ติดตั้ง dependencies และ build frontend
RUN cd client && npm install && npm run build


# ---------- Stage 2: Final Image ----------
FROM node:20-alpine
WORKDIR /app

# 1. ก๊อปปี้โฟลเดอร์ server มาไว้ที่ /app/server
COPY server/ ./server/

# 2. ก๊อปปี้ไฟล์ที่ Build เสร็จจาก Stage แรก มาไว้ที่ /app/client/build
COPY --from=client-build /app/client/build ./client/build

# 3. ติดตั้ง server dependencies
RUN cd server && npm install --omit=dev

# ตั้งค่า Environment
ENV PORT=7000
EXPOSE 7000

# --- จุดสำคัญ: วิธีการรัน ---
# เราอยู่ที่ /app ดังนั้นต้องเรียกไฟล์ที่อยู่ในโฟลเดอร์ server
CMD ["node", "server/server.js"]