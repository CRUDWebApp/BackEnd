import { Router } from "express";
import type { Request, Response } from "express";
import { Prisma } from "@prisma/client";
import { prisma } from "../prisma.js";

const router: Router = Router();

// POST - /api/create
router.post("/create", async (request: Request, response: Response) => {
    try {
        // Basic validation
        const { name, email } = request.body;
        if (!name || !email) {
            return response.status(400).json({
                success: false,
                message: "Missing required fields: studentid, name, email"
            });
        }

        const currentyear = new Date().getFullYear.toString().slice(-2);


        const user = await prisma.$transaction(async (tx) => {
            
            // Tìm user có ID (số thứ tự) lớn nhất hiện tại
            const lastUser = await tx.user.findFirst({
                orderBy: { id: 'desc' }
            });

            const nextId = (lastUser?.id || 0) + 1;

            // 3. Ghép chuỗi tạo studentid. 
            // Dùng padStart để luôn có 4 chữ số (VD: 260001, 260015, 261234)
            const generatedStudentId = `${currentYearPrefix}${String(nextId).padStart(4, '0')}`;

            // 4. Tạo user mới với studentid vừa tự sinh
            return await tx.user.create({
                data: { 
                    studentid: generatedStudentId, 
                    name, 
                    email 
                }
            });
        });

        return response.status(201).json({
            success: true,
            message: "Create successfully",
            data: user
        });

    } catch (error) {
        if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
            return response.status(409).json({
                success: false,
                message: "Student's ID or Email already exists", // Đảm bảo email cũng không bị trùng nếu DB có set unique
            });
        }

        return response.status(500).json({
            success: false,
            message: "Create failed",
            error: error instanceof Error ? error.message : String(error),
        });
    }
}); 

// GET - /api/getinfor
router.get("/getinfor", async (request: Request, response: Response) => {
    try {
        const users = await prisma.user.findMany();
        return response.json({
            success: true,
            data: users
        });
    } catch (error) {
        return response.status(500).json({
            success: false,
            message: "Failed to fetch users",
            error: error instanceof Error ? error.message : String(error),
        });
    }
});

// DELETE - /api/delete/:studentid
router.delete("/delete/:studentid", async (request: Request, response: Response) => {
    try {
        await prisma.user.delete({
            where: {
                studentid: String(request.params.studentid)
            }
        });

        return response.json({
            success: true,
            message: "Delete successfully"
        });
    } catch (error) {
        // P2025 là mã lỗi của Prisma khi không tìm thấy record để xoá
        if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2025") {
            return response.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        return response.status(500).json({
            success: false,
            message: "Delete failed",
            error: error instanceof Error ? error.message : String(error),
        });
    }
});

// PUT - /api/update/:studentid
router.put("/update/:studentid", async (request: Request, response: Response) => {
    try {
        const { name, email } = request.body;

        const user = await prisma.user.update({
            where: {
                studentid: String(request.params.studentid)
            },
            data: { name, email }
        });

        return response.json({
            success: true,
            message: "Update successfully",
            data: user
        });

    } catch (error) {
        // Xử lý lỗi không tìm thấy user để update
        if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2025") {
            return response.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        return response.status(500).json({
            success: false,
            message: "Update failed",
            error: error instanceof Error ? error.message : String(error),
        });
    }
});

export default router;