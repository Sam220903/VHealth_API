<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

global $connection;

spl_autoload_register(function ($class) {
    $directories = [
        __DIR__ . "/../src/config/",
        __DIR__ . "/../src/controllers/",
        __DIR__ . "/../src/services/",
        __DIR__ . "/../src/models/",
        __DIR__ . "/../src/middleware/",
        __DIR__ . "/../src/helpers/"
    ];

    foreach ($directories as $directory) {
        $file = $directory . $class . ".php";
        if (file_exists($file)) {
            require $file;
            return;
        }
    }
});

include_once '../src/config/header.php';
$configPath = __DIR__ . '/../src/config/config.php';
if (!file_exists($configPath)) {
    die("Error: El archivo de configuración no existe en la ruta esperada.");
}
include_once $configPath;

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Just exit with 200 OK status
    http_response_code(200);
    exit();
}

// Única conexión a la base de datos
$database = new Database($connection["servername"], $connection["username"], $connection["password"], $connection["dbname"]);
$dbConnection = $database->getConnection(); // Ensure you get the connection object

// Obtener la ruta y el ID desde la URL
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$parts = explode('/', trim($path, '/'));
$lastIndex = count($parts) - 1;
$route = $parts[$lastIndex - 1] ?? null;
$id = $parts[$lastIndex] ?? null;

// Si el id no es numérico, entonces es una ruta
if (!is_numeric($id)) {
    $route = $id;
    $id = null;
}


switch($route){
    // Ruta para obtener todos los usuarios
    case "test":
        echo json_encode(["php_version" => phpversion()]);
        break;


    case "exercises":
        $exerciseService = new ExerciseService($dbConnection); // Pass the connection object
        $exerciseController = new ExerciseController($exerciseService);
        try {
            $exerciseController->processRequest($_SERVER['REQUEST_METHOD'], $id);
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case "routines" :
        $routineService = new RoutineService($dbConnection); // Pass the connection object
        $routineController = new RoutineController($routineService);
        try {
            $routineController->processRequest($_SERVER['REQUEST_METHOD'], $id);
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;
    


}
