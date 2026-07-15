    FROM node:22-alpine

    WORKDIR /app

    COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

    RUN npm install -g pnpm

    RUN pnpm install --frozen-lockfile


    ENV CI=true

    COPY . .

    RUN pnpm prisma generate

    RUN pnpm build

    EXPOSE 3000

    CMD ["pnpm", "start"]