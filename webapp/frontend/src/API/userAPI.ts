import api from "./axios";

export const getUsers = () => api.get("/users");

export const getUser = (id: number) =>
  api.get(`/users/${id}`);

export const createUser = (data: unknown) =>
  api.post("/users", data);

export const updateUser = (id: number, data: unknown) =>
  api.put(`/users/${id}`, data);

export const deleteUser = (id: number) =>
  api.delete(`/users/${id}`);