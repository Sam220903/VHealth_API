<?php

class RoutineService {
    //Declaración de variables de la clase
    private $conn;

    // Constructor (recibe conexión de base de datos)
    public function __construct(PDO $dbConnection) {
        $this->conn = $dbConnection;
    }

    public function getRoutines() {
        $sql = "SELECT * FROM vh_routines;";
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
        $sql = "SELECT exercise_id, sort_order, name AS 'exercise', repetitions, body_zone, ai_parameters
                    FROM vh_routines_exercises re
                    JOIN vh_exercises e ON (re.exercise_id = e.id)
                    WHERE routine_id = :id;";
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