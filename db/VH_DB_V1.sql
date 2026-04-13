CREATE TABLE vh_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vh_exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    body_zone VARCHAR(50) NOT NULL,
    ai_parameters JSON NOT NULL
);

CREATE TABLE vh_routines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT, -- Nuevo campo de descripción
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES vh_users(id) ON DELETE CASCADE
);

CREATE TABLE vh_routines_exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    routine_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sort_order INT NOT NULL,
    repetitions INT NOT NULL,
    FOREIGN KEY (routine_id) REFERENCES vh_routines(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES vh_exercises(id) ON DELETE CASCADE
);

INSERT INTO vh_exercises (name, description, body_zone, ai_parameters) VALUES 
(
    'Sentadillas', 
    'Ejercicio compuesto fundamental para fortalecer cuádriceps, glúteos e isquiotibiales. Mantén la espalda recta y baja hasta que tus muslos estén paralelos al suelo.', 
    'Tren inferior', 
    '{
        "key_points": [23, 25, 27], 
        "joint": "rodilla", 
        "threshold_start": 160, 
        "threshold_contract": 100, 
        "logic_state": "descending"
    }'
),
(
    'Elevaciones de talón', 
    'Movimiento de aislamiento enfocado en el desarrollo de los músculos de la pantorrilla (gastrocnemio y sóleo). Eleva los talones lo más posible apoyándote en la punta de los pies.', 
    'Tren inferior', 
    '{
        "key_points": [25, 27, 31], 
        "joint": "tobillo", 
        "threshold_start": 110, 
        "threshold_contract": 135, 
        "logic_state": "ascending"
    }'
),
(
    'Desplantes (Zancadas)', 
    'Da un paso hacia adelante y baja la cadera hasta que ambas rodillas formen un ángulo de 90 grados. Mantén el torso recto. Vuelve a la posición inicial.', 
    'Tren inferior', 
    '{
        "key_points": [23, 25, 27], 
        "joint": "rodilla", 
        "threshold_start": 160, 
        "threshold_contract": 100, 
        "logic_state": "descending"
    }'
),
(
    'Elevación de rodilla de pie', 
    'Estando de pie, levanta una rodilla lo más alto que puedas hacia tu pecho, manteniendo la espalda recta. Baja la pierna y repite.', 
    'Tren inferior / Cardio', 
    '{
        "key_points": [11, 23, 25], 
        "joint": "cadera", 
        "threshold_start": 170, 
        "threshold_contract": 110, 
        "logic_state": "descending"
    }'
);



-- Insertamos las 4 cabeceras de rutinas con sus descripciones
INSERT INTO vh_routines (name, description) VALUES 
('Sentadillas', 'Sesión rápida enfocada en activar la circulación de las piernas y fortalecer glúteos.'),
('Elevaciones de talón', 'Ideal para fortalecer pantorrillas y mejorar el retorno venoso mientras trabajas de pie.'),
('Desplantes (Zancadas)', 'Entrenamiento de estabilidad y fuerza unilateral para piernas y core.'),
('Elevación de rodilla de pie', 'Pausa activa de intensidad media para mejorar la movilidad de cadera y elevar el ritmo cardíaco.');

-- El vínculo en vh_routines_exercises se mantiene igual (IDs 1 al 4)
INSERT INTO vh_routines_exercises (routine_id, exercise_id, sort_order, repetitions) VALUES 
(1, 1, 1, 10),
(2, 2, 1, 10),
(3, 3, 1, 10),
(4, 4, 1, 10);