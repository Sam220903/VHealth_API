-- 1. LIMPIEZA FORZADA DE TABLAS
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS vh_routines_exercises;
DROP TABLE IF EXISTS vh_routines;
DROP TABLE IF EXISTS vh_exercises;
DROP TABLE IF EXISTS vh_users;
SET FOREIGN_KEY_CHECKS = 1;

-- 2. CREACIÓN DE TABLAS (Con el ENUM de zonas del cuerpo y Motor InnoDB)
CREATE TABLE vh_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE vh_exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    body_zone ENUM('Tren superior', 'Tren inferior', 'Zona media') NOT NULL,
    ai_parameters JSON NOT NULL,
    video_url VARCHAR(255) DEFAULT NULL -- Columna lista para los videos MP4
) ENGINE=InnoDB;

CREATE TABLE vh_routines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES vh_users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE vh_routines_exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    routine_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sort_order INT NOT NULL,
    repetitions INT NOT NULL,
    FOREIGN KEY (routine_id) REFERENCES vh_routines(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES vh_exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. INSERCIÓN DE EJERCICIOS (Nuestros 5 ganadores refinados)
INSERT INTO vh_exercises (id, name, description, body_zone, ai_parameters, video_url) VALUES 
-- Ejercicio 1: Sentadillas (Rodilla dobla: 180 baja a 100)
(1, 'Sentadillas', 'Ejercicio compuesto para cuádriceps y glúteos. Mantén la espalda recta y baja hasta que tus muslos estén paralelos al suelo.', 'Tren inferior', 
'{ "key_points": [23, 25, 27],
     "joint": "rodilla", 
     "threshold_start": 150, 
     "threshold_contract": 115, 
     "logic_state": "descending"}', 
     '/videos/squats.mp4'),

-- Ejercicio 2: Desplantes / Zancadas (Rodilla dobla: 180 baja a 100)
(2, 'Desplantes (Zancadas)', 'Da un paso hacia adelante y baja la cadera hasta que ambas rodillas formen un ángulo de 90 grados. Mantén el torso recto.', 'Tren inferior', '{"key_points": [23, 25, 27], "joint": "rodilla", "threshold_start": 160, "threshold_contract": 100, "logic_state": "descending"}', '/videos/lunge_exercise.mp4'),

-- Ejercicio 3: Elevación de rodilla de pie (Cadera dobla: 180 baja a 110)
(3, 'Elevación de rodilla de pie', 'Levanta una rodilla lo más alto que puedas hacia tu pecho, manteniendo la espalda recta.', 'Tren inferior', '{"key_points": [11, 23, 25], "joint": "cadera", "threshold_start": 160, "threshold_contract": 110, "logic_state": "descending"}', '/videos/knee_raises.mp4'),

-- Ejercicio 4: Elevación frontal de brazos (Hombro se abre: 30 sube a 150)
(4, 'Estiramiento frontal de brazos', 'Eleva ambos brazos extendidos por delante de ti hasta que queden por encima de tu cabeza, y bájalos lentamente.', 'Tren superior', '{"key_points": [23, 11, 13], "joint": "hombro_vertical", "threshold_start": 60, "threshold_contract": 160, "logic_state": "ascending"}', NULL),

-- Ejercicio 5: Elevación lateral de brazos (Hombro se abre hacia afuera: 20 sube a 85)
(5, 'Elevación lateral de brazos', 'Eleva ambos brazos hacia los lados hasta que formen una "T" paralela al piso y bájalos controladamente.', 'Tren superior', '{"key_points": [12, 11, 13], "joint": "hombro_horizontal", "threshold_start": 110, "threshold_contract": 165, "logic_state": "ascending"}', '/videos/side_arm_raises.mp4');

-- 4. INSERCIÓN DE RUTINAS SIMPLES
INSERT INTO vh_routines (id, name, description) VALUES 
(1, 'Sentadillas', 'Sesión rápida enfocada en activar la circulación de las piernas y fortalecer glúteos.'),
(2, 'Desplantes (Zancadas)', 'Entrenamiento de estabilidad y fuerza unilateral para piernas y core.'),
(3, 'Elevación de rodilla de pie', 'Pausa activa de intensidad media para mejorar la movilidad de cadera y elevar el ritmo cardíaco.'),
(4, 'Estiramiento frontal', 'Pausa activa ideal para relajar los hombros y abrir el pecho después de pasar horas frente al teclado.'),
(5, 'Elevación lateral de brazos', 'Pausa activa para mejorar la postura de los hombros y combatir el encorvamiento frente al monitor.');

-- 5. VINCULACIÓN RUTINA -> EJERCICIO
INSERT INTO vh_routines_exercises (routine_id, exercise_id, sort_order, repetitions) VALUES 
(1, 1, 1, 10),
(2, 2, 1, 10),
(3, 3, 1, 10),
(4, 4, 1, 10),
(5, 5, 1, 10);