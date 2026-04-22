# ---------- Stage 1: Build React (Frontend) ----------
FROM node:20-alpine AS client-build
# กำหนดจุดทำงานหลักที่ /app
WORKDIR /app

# ก๊อปปี้ package.json โดยระบุ path จาก root ของโปรเจกต์
# (ตรวจสอบให้แน่ใจว่าชื่อโฟลเดอร์ client เป็นตัวเล็กทั้งหมดตรงตามเครื่อง)
COPY client/package*.json ./client/

# ย้ายเข้าไปรัน npm install ในโฟลเดอร์ client
WORKDIR /app/client
RUN npm install

# ก๊อปปี้ไฟล์ทั้งหมดของ client เข้าไปเพื่อ build
COPY client/ ./
RUN npm run build


# ---------- Stage 2: Build Server (Backend) & Final Image ----------
FROM node:20-alpine
WORKDIR /app

# 1. จัดการส่วนของ Server
COPY server/package*.json ./server/
# ใช้ --omit=dev แทน --production (แนะนำสำหรับ npm เวอร์ชั่นใหม่)
RUN cd server && npm install --omit=dev

# ก๊อปปี้โค้ด server ทั้งหมดเข้าไป
COPY server/ ./server/

# 2. ก๊อปปี้ไฟล์ที่ Build เสร็จแล้วจาก Stage แรกมาไว้ที่ Server
# (ตรวจสอบว่าใน server.js ของคุณเรียกใช้ไฟล์จาก path ไหน)
COPY --from=client-build /app/client/build ./client/build

# ตั้งค่า Environment
ENV PORT=7000
EXPOSE 7000

# รัน server (ตรวจสอบว่า server.js อยู่ในโฟลเดอร์ server/ หรือไม่)
# ถ้า server.js อยู่ในโฟลเดอร์ server ให้ใช้: CMD ["node", "server/server.js"]
WORKDIR /app/server
CMD ["node", "server.js"]