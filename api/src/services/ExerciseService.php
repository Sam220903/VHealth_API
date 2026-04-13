<?php

class ExerciseService {
    //Declaración de variables de la clase
    private $conn;

    // Constructor (recibe conexión de base de datos)
    public function __construct(PDO $dbConnection) {
        $this->conn = $dbConnection;
    }

    public function getExercises() {
        $sql = "SELECT * FROM vh_exercises;";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getExercisePerID(string $exercise_id) {
        $sql = "SELECT * FROM vh_exercises WHERE id = :id;";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':id', $exercise_id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }    

}