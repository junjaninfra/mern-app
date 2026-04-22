# ---------- Stage 1: Build React ----------
FROM node:20-alpine AS client-build
WORKDIR /app

# 1. ก๊อปปี้ทุกอย่างจาก root เครื่องคุณ เข้าไปใน container ให้หมดก่อน
COPY . .

# 2. ตรวจสอบไฟล์ (ถ้ามัน Error อีก ให้คุณไปดูใน Console Output ของ Jenkins จะเห็นรายชื่อไฟล์)
RUN ls -R

# 3. ลองรัน npm install โดยระบุ path ตรงๆ ไม่ต้องสลับ WORKDIR ไปมา
RUN cd client && npm install

# 4. Build React
RUN cd client && npm run build


# ---------- Stage 2: Final Image ----------
FROM node:20-alpine
WORKDIR /app

# ก๊อปปี้ทุกอย่างกลับมา
COPY . .

# จัดการ Server
RUN cd server && npm install --omit=dev

# ก๊อปปี้ไฟล์ที่ Build เสร็จจาก Stage แรก
COPY --from=client-build /app/client/build ./client/build

ENV PORT=7000
EXPOSE 7000

# ตรวจสอบว่าไฟล์ server.js อยู่ที่ไหน (สมมติว่าอยู่ใน /app/server/server.js)
CMD ["node", "server/server.js"]