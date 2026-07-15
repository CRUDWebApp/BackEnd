import { Router } from "express";
import { timeStamp } from "node:console";
const router = Router();
//POST-/api/create
router.get("/create", (request, response) => {
    response.status(200).json({
        success: true,
        message: "Successfully Create",
        data: request.body,
        timestamp: new Date().toISOString()
    });
});
//GET-/api/getinfor
router.get("/getinfor", (request, response) => {
    response.status(201).json({
        success: true,
        message: "Get Informationn Successfully ",
        method: "GET",
        timestamp: new Date().toISOString()
    });
});
//DELETE-/api/delete/:id
router.get("/delete/:id", (request, response) => {
    response.status(200).json({
        success: true,
        message: `Delete ${request.params.id} successfully`,
        timestamp: new Date().toISOString()
    });
});
export default router;
//# sourceMappingURL=APIroute.js.map