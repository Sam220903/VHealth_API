CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    body_zone VARCHAR(50) NOT NULL,
    ai_parameters JSON NOT NULL
);

CREATE TABLE routines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE routines_exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    routine_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sort_order INT NOT NULL,
    repetitions INT NOT NULL,
    FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

INSERT INTO exercises (name, description, body_zone, ai_parameters) VALUES 
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
);