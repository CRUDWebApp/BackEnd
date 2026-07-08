import { Router } from "express"
import type { Request, Response } from "express";
import { timeStamp } from "node:console";

const router: Router = Router();

//POST-/api/create
router.post("/create", (request: Request, response: Response ) => {
    response.status(200).json({
        method: "POST",
        success: true,
        message: "Successfully Create",
        data: request.body,
        timestamp: new Date().toISOString()
    });
}); 

//GET-/api/getinfor
router.get("/getinfor", (request: Request, response: Response ) => {
    response.status(201).json({
        success: true,
        message: "Get Informationn Successfully ",
        method: "GET",
        timestamp: new Date().toISOString()
    });
}); 

//DELETE-/api/delete/:id
router.delete("/delete/:id", (request: Request, response: Response ) => {

    response.status(200).json({
        success: true,
        message: `Delete ${request.params.id} successfully`,
        timestamp: new Date().toISOString()
    });
}); 

export default router