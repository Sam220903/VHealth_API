<?php

class Exercise {
    private ?int $id;
    private string $name;
    private string $description;
    private string $bodyZone;
    private array $aiParameters;

    public function __construct(
        ?int $id, 
        string $name, 
        string $description, 
        string $bodyZone, 
        array $aiParameters
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
        $this->bodyZone = $bodyZone;
        $this->aiParameters = $aiParameters;
    }

    // --- Getters ---
    public function getId(): ?int { 
        return $this->id; 
    }

    public function getName(): string { 
        return $this->name; 
    }

    public function getDescription(): string { 
        return $this->description; 
    }

    public function getBodyZone(): string { 
        return $this->bodyZone; 
    }

    public function getAiParameters(): array { 
        return $this->aiParameters; 
    }

    // --- Setters ---
    public function setName(string $name): void { 
        $this->name = $name; 
    }

    public function setDescription(string $description): void { 
        $this->description = $description; 
    }

    public function setBodyZone(string $bodyZone): void { 
        $this->bodyZone = $bodyZone; 
    }

    public function setAiParameters(array $aiParameters): void { 
        $this->aiParameters = $aiParameters; 
    }

    // --- Método para convertir el objeto a arreglo (Útil para el Controlador) ---
    public function toArray(): array {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'body_zone' => $this->bodyZone,
            'ai_parameters' => $this->aiParameters
        ];
    }
}