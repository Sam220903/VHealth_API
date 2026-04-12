<?php

class ExerciseController {
    private $service; 

    public function __construct(ExerciseService $service){
        $this->service = $service;
        // Agregar el payload cuando esa parte este terminada
    }
    // Procesar las solicitudes según su tipo (recurso o colección)
    public function processRequest(string $method, ?string $id) {
        if ($id){
            $this->processResourceRequest($method, $id);
        } else {
            $this->processCollectionRequest($method);
        }
    }
    // Procesar solicitudes de recurso (una sola instancia)
    public function processResourceRequest(string $method, string $id){
        switch($method){
            case 'GET':
                $exercise = $this->service->getExercisePerID($id);
                $exercise = TypeCaster::castRow($exercise);
                echo json_encode($exercise);
                break;

            default: break;
        }
    }
    // Procesar solicitudes de colección (Varias instancias, una tabla)
    public function processCollectionRequest(string $method){
        switch ($method) {
            case 'GET':
                $exercises = $this->service->getExercises();
                $exercises = TypeCaster::castRows($exercises);
                echo json_encode($exercises);
                break;
            
            default:
                break;
        }
    }
}