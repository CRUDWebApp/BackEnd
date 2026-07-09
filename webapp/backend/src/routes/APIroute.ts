import { response, Router } from "express"
import type { Request, Response } from "express";
import { timeStamp } from "node:console";
import { prisma } from "../prisma.js";

const router: Router = Router();

//POST-/api/create
router.post("/create", async (request: Request, response: Response ) => {
    try {

        const user = await prisma.user.create({
            data: {
                name: request.body.name,
                email: request.body.email
            }
        });

        response.status(201).json({
            success: true,
            message: "Create successfully",
            data: user
        });

    } catch (error) {

        response.status(500).json({
            success: false,
            message: "Create failed",
            error
        });

    }
}); 

//GET-/api/getinfor
router.get("/getinfor", async (request: Request, response: Response) => {

    const users = await prisma.user.findMany();

    response.json({
        success: true,
        data: users
    });

});

//DELETE-/api/delete/:id

router.delete("/delete/:id", async (request: Request, response: Response) => {

    await prisma.user.delete({

        where: {
            id: Number(request.params.id)
        }

    });

    response.json({
        success: true,
        message: "Delete successfully"
    });

});
export default router