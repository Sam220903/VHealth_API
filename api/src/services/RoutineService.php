<?php

class RoutineService {
    //Declaración de variables de la clase
    private $conn;

    // Constructor (recibe conexión de base de datos)
    public function __construct(PDO $dbConnection) {
        $this->conn = $dbConnection;
    }

    public function getRoutines() {
        $sql = 'WITH ZonasPorRutina AS (
                    SELECT 
                        re.routine_id,
                        CASE 
                            -- Si solo hay 1 zona de cuerpo distinta, devolvemos esa zona
                            WHEN COUNT(DISTINCT e.body_zone) = 1 THEN MAX(e.body_zone)
                            -- Si hay más de 1, devolvemos "Mixto"
                            ELSE "Mixto" 
                        END AS computed_zone
                    FROM vh_routines_exercises re
                    JOIN vh_exercises e ON re.exercise_id = e.id
                    GROUP BY re.routine_id
                )
                SELECT 
                    r.id, 
                    r.user_id, 
                    r.name, 
                    r.description, 
                    r.creation_date,
                    -- Aquí usamos COALESCE por si la rutina aún no tiene ejercicios asignados
                    COALESCE(zpr.computed_zone, "Sin ejercicios") AS body_zone 
                FROM vh_routines r
                LEFT JOIN ZonasPorRutina zpr ON r.id = zpr.routine_id;';
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function getRoutineDetails(string $routine_id) {
        $sql = "SELECT * FROM vh_routines WHERE id = :id;";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':id', $routine_id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    private function getRoutineExercises(string $routine_id){
        $sql = "SELECT exercise_id, sort_order, name, repetitions, body_zone, ai_parameters, video_url
                    FROM vh_routines_exercises re
                    JOIN vh_exercises e ON (re.exercise_id = e.id)
                    WHERE routine_id = :id
                    ORDER BY sort_order;";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':id', $routine_id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getRoutinePerID(string $routine_id){
        $details = $this->getRoutineDetails($routine_id);
        $exercises = $this->getRoutineExercises($routine_id);
        return array(
            'routine_details' => $details,
            'exercises' => $exercises
        );
    }

}