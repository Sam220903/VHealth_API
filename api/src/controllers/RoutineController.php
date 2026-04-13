<?php

class RoutineController {
    private $service; 

    public function __construct(RoutineService $service){
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
                $routine = $this->service->getRoutinePerID($id);
                $routine = TypeCaster::castRow($routine);
                echo json_encode($routine);
                break;

            default: break;
        }
    }
    // Procesar solicitudes de colección (Varias instancias, una tabla)
    public function processCollectionRequest(string $method){
        switch ($method) {
            case 'GET':
                $routines = $this->service->getRoutines();
                $routines = TypeCaster::castRows($routines);
                echo json_encode($routines);
                break;
            
            default:
                break;
        }
    }
}