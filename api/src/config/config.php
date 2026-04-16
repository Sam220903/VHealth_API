<?php

// Conexión en entorno Linux (Pila LAMP)
$connection = [
    "servername" => "localhost",
    "username" => "root",
    "password" => "@Hazard3654",
    "dbname" => "vh_db"
];

// Conexión en producción
// $connection = [
//     "servername" => "localhost",
//     "username" => "root",
//     "password" => "root",
//     "dbname" => "vh_db"
// ];

// Conexión usando contenedor docker
// $connection = [
//     "servername" => "vhealth_db",
//     "username" => "vh_user",
//     "password" => "#VHealth10",
//     "dbname" => "vh_db"
// ];