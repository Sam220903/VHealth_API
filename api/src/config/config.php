<?php

// Conexión en entorno Linux (Pila LAMP)
$connection = [
    "servername" => "localhost",
    "username" => "root",
    "password" => "",
    "dbname" => "vh_db"
];

// Conexión usando contenedor docker
// $connection = [
//     "servername" => "vhealth_db",
//     "username" => "vh_user",
//     "password" => "#VHealth10",
//     "dbname" => "vh_db"
// ];