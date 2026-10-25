### 📊 PlayLoop Project 

## 💼 Executive Summary 

### 🎯 Key Findings

### 🤝 Business Implication

## 📁 Project structure
```
BrightCart Project/
├── data/                   # Main folder for data
│   ├── raw/                # Original data (immutable, never overwritten)
│   └── processed/          # Clean and final data ready for modeling or visualization
│
├── notebooks/              # Jupyter notebooks
│   └── 
│
├── outputs/                # Generated reports, presentations, or dashboards
│   └── 
│
├── sql/                    # Querys
│   └── 
│
├── .gitignore              # Files and folders that Git should ignore (e.g., /data/raw, .env)
├── README.md               # Main project documentation (objectives, how to run it)
└── requirements.txt        # Python dependencies (pandas, matplotlib, seaborn, etc.)

```
## 🗄️ Data Model (Entity-Relationship)
```mermaid
erDiagram
    %% Relaciones (Entity-Relationship)
    USERS ||--o{ SESSIONS : "registra"
    USERS ||--o{ MATCHES : "juega"
    USERS ||--o{ PURCHASES_IAP : "realiza"
    USERS ||--o{ INGRESOS_ADS : "genera"
    UA_SPEND ||--o{ USERS : "adquiere mediante"
    IAP_PRODUCTS ||--o{ PURCHASES_IAP : "es comprado en"

    %% Definición de Tablas y Columnas
    USERS {
        varchar user_id PK
        varchar canal FK
        varchar pais
        varchar plataforma
    }

    SESSIONS {
        varchar user_id FK
        date fecha
        int duracion
    }

    MATCHES {
        varchar user_id FK
        int nivel
        varchar resultado
    }

    PURCHASES_IAP {
        varchar user_id FK
        varchar producto_id FK
        float importe
    }

    INGRESOS_ADS {
        varchar user_id FK
        varchar tipo_ad
        float ingreso
    }

    IAP_PRODUCTS {
        varchar producto_id PK
        float precio
    }

    UA_SPEND {
        varchar canal PK "por canal, no por jugador"
        float gasto
        int instalaciones
    }
```

## 🧰 Tech Stack 
- Analysis: Python, Pandas, PostgreSQL
- Visualization: Matplotlib
- Reporting: Jupyter Notebook
- Version Control: Git / GitHub

## 👤 Autor

Jimmy Ramírez — [LinkedIn](https://www.linkedin.com/in/jimmy-ramirez-g) · [GitHub](https://github.com/jimmyramirezg6-blip)
