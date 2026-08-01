CREATE UNIQUE INDEX unique_nombre_rutina_predeterminada 
ON "Rutinas" (user_id, nombre) 
WHERE es_predeterminada = true;
