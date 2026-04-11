# BuildHome VN -- Smart Home Construction Assistant

## 1. Product Overview

BuildHome VN is a mobile application designed to help users (especially
in rural areas) estimate construction materials, costs, and explore
house designs without requiring technical knowledge.

## 2. Objectives

-   Estimate construction materials (cement, sand, steel, etc.)
-   Calculate approximate costs
-   Provide house design references (Thai roof, Japanese roof, etc.)
-   Support input via manual entry or image scanning

------------------------------------------------------------------------

## 3. User Personas

### Homeowners

-   Age: 30--55
-   Limited construction knowledge
-   Want cost and material estimation

### Builders

-   Need quick material calculations
-   Use app for quotations

------------------------------------------------------------------------

## 4. User Flows

### Flow 1: Quick Estimation

1.  Open app
2.  Select "Calculate Materials"
3.  Input:
    -   Land dimensions
    -   Number of floors
    -   House type
4.  View results

### Flow 2: Image Scan

1.  Select "Scan House"
2.  Take photo
3.  AI detects house type
4.  Suggest similar designs

### Flow 3: Browse Templates

1.  Open "House Templates"
2.  Filter by type
3.  Select a design

### Flow 4: Export Report

1.  Generate estimation
2.  Export to PDF

------------------------------------------------------------------------

## 5. Features

### 5.1 Material Estimation (Core)

Inputs: - Width, Length - Floors - House type

Outputs: - Cement (bags) - Sand (m³) - Stone (m³) - Steel (kg/tons)

Basic Formula: - Floor area = width × length × floors - Steel ≈ area ×
90kg - Concrete ≈ area × 0.25 m³ - Cement ≈ concrete × 300kg/m³ - Sand ≈
concrete × 0.5 - Stone ≈ concrete × 0.8

------------------------------------------------------------------------

### 5.2 Cost Estimation

-   Material cost based on local pricing
-   Total cost breakdown:
    -   Structural
    -   Finishing

------------------------------------------------------------------------

### 5.3 Image Recognition (Phase 2)

-   Detect house type from photo
-   Tech: TensorFlow Lite / OpenCV

------------------------------------------------------------------------

### 5.4 House Template Library

Data: - Name - Type - Area - Image - Estimated cost

------------------------------------------------------------------------

### 5.5 PDF Export

Includes: - House info - Material list - Cost estimation

------------------------------------------------------------------------

## 6. System Architecture

### Frontend

-   Flutter (recommended)
-   React Native (alternative)

### Backend

-   Firebase (MVP)
-   Node.js (scalable)

### AI (Future)

-   Python + FastAPI

------------------------------------------------------------------------

## 7. Database Design

### Users

-   id, name, phone

### Projects

-   id, user_id, dimensions, floors, type

### Materials

-   project_id, cement, sand, steel

### Templates

-   id, name, type, image, cost

------------------------------------------------------------------------

## 8. Development Roadmap

### Phase 1 (MVP)

-   UI for input & results
-   Material calculation logic
-   Template listing

### Phase 2

-   AI image recognition
-   AR measurement

### Phase 3

-   Payment system
-   Ads & affiliate integration

------------------------------------------------------------------------

## 9. UI/UX Principles

-   Simple interface
-   Minimal text
-   Large buttons

Main screen: - Calculate Materials - Scan House - House Templates

------------------------------------------------------------------------

## 10. Risks & Mitigation

### Inaccurate Estimation

-   Add disclaimer: "For reference only. Not a replacement for
    engineers."

### User Difficulty

-   Simple UX
-   Tutorial videos

------------------------------------------------------------------------

## 11. KPIs

-   App downloads
-   Number of calculations
-   Conversion to paid users

------------------------------------------------------------------------

## 12. Future Expansion

-   Contractor marketplace
-   Material e-commerce
-   AI house design

## 13. Details Requirement
1. PRODUCT OVERVIEW

🎯 Project Name (Temporary)

BuildHome VN – Smart Home Construction Assistant

🎯 Objectives
	•	Help users (especially in rural areas) to:
	•	Estimate construction materials
	•	Calculate building costs
	•	Explore house design templates
	•	No technical knowledge required

⸻

👤 2. USER PERSONAS

Persona 1 – Homeowner
	•	Age: 30–55
	•	No construction expertise
	•	Wants to know:
	•	Total cost to build a house
	•	Required materials

Persona 2 – Builder / Contractor
	•	Needs quick material estimation
	•	Uses the app for quotations

⸻

🔄 3. USER FLOWS (Main Scenarios)

Flow 1 – Quick Estimation
	1.	Open the app
	2.	Select:
	•	“Calculate Materials”
	3.	Input:
	•	Land size (e.g., 5x20)
	•	Number of floors
	•	House type
	4.	Tap “Calculate”
	5.	View results:
	•	Materials
	•	Cost

⸻

Flow 2 – House Scan
	1.	Select “Scan House”
	2.	Take a photo
	3.	AI analyzes:
	•	House type
	4.	Suggestions:
	•	Similar templates
	•	Suggested area
	5.	User adjusts → calculate materials

⸻

Flow 3 – Browse House Templates
	1.	Go to “House Templates”
	2.	Select:
	•	Thai roof / Japanese roof / modern
	3.	View:
	•	Images
	•	Area
	•	Cost
	4.	Tap “Use this template”

⸻

Flow 4 – Export Report
	1.	After calculation
	2.	Tap “Export PDF”
	3.	Receive file:
	•	Materials
	•	Cost

⸻

📱 4. FEATURE REQUIREMENTS

⸻

🧮 4.1 Material Estimation (CORE)

Input
	•	Width (m)
	•	Length (m)
	•	Number of floors
	•	House type:
	•	Thai roof
	•	Japanese roof
	•	Flat roof

Output
	•	Total construction area
	•	Cement (bags)
	•	Sand (m³)
	•	Stone (m³)
	•	Steel (kg/tons)

Logic (MVP)
	•	Floor area = width × length × floors
	•	Steel = area × 90 kg
	•	Concrete = area × 0.25 m³
	•	Cement ≈ concrete × 300 kg/m³
	•	Sand ≈ concrete × 0.5
	•	Stone ≈ concrete × 0.8

⸻

💰 4.2 Cost Estimation

Input
	•	Material prices (configurable by region)

Output
	•	Total structural cost
	•	Total finishing cost

Formula
	•	Cost = material × unit price

⸻

📸 4.3 Image Scan (AI – Phase 2)

Input
	•	House image

Output
	•	House type:
	•	Thai roof
	•	Japanese roof
	•	Tube house

Technology
	•	TensorFlow Lite / OpenCV

⸻

🏠 4.4 House Template Library

Data
	•	id
	•	name
	•	roof type
	•	area
	•	image
	•	estimated cost

Features
	•	Filters:
	•	Area
	•	Number of floors

⸻

📄 4.5 PDF Export

Contents
	•	House information
	•	Material list
	•	Cost estimation

⸻

🧱 5. SYSTEM ARCHITECTURE

📱 Frontend
	•	Flutter (recommended)
	•	or React Native

⚙️ Backend
	•	Firebase (for fast MVP)
	•	or Node.js

🧠 AI (Future Phase)
	•	Python service (FastAPI)

⸻

🗂️ 6. DATABASE DESIGN

Table: users
	•	id
	•	name
	•	phone

Table: projects
	•	id
	•	user_id
	•	area
	•	number_of_floors
	•	house_type

Table: materials
	•	project_id
	•	cement
	•	sand
	•	steel

Table: house_templates
	•	id
	•	name
	•	type
	•	image
	•	cost_estimate

⸻

🧩 7. TASK BREAKDOWN (DEVELOPMENT)

⸻

🚀 PHASE 1 – MVP (2–4 weeks)

🔹 Frontend
	•	UI for inputting dimensions
	•	UI for selecting house type
	•	UI for displaying results
	•	UI for house template list

🔹 Backend
	•	Material calculation API
	•	House template API

🔹 Logic
	•	Implement material calculation formulas

⸻

🚀 PHASE 2 – Advanced Features

AI
	•	House recognition from images
	•	Roof type classification

AR
	•	Measure dimensions using camera

⸻

🚀 PHASE 3 – Monetization
	•	Pro subscription
	•	Ads integration
	•	Affiliate partnerships (building materials)

⸻

🎨 8. UI/UX REQUIREMENTS

Principles
	•	Very simple
	•	Minimal text
	•	Clear icons

Main Screen
	•	3 large buttons:
	•	📐 Calculate Materials
	•	📸 Scan House
	•	🏠 House Templates

⸻

⚠️ 9. RISKS & SOLUTIONS

❌ Material estimation inaccuracy

👉 Solution:
	•	Display disclaimer:
“For reference only. Not a substitute for professional engineers.”

❌ Users lack technical knowledge

👉 Solution:
	•	Tutorial videos
	•	Extremely simple UI

⸻

📊 10. KPIs
	•	Number of app downloads
	•	Number of calculations performed
	•	Conversion rate to Pro users

⸻

🧠 BONUS – FUTURE EXPANSION
	•	Marketplace:
	•	Connect homeowners with builders
	•	Sell construction materials
	•	AI-powered house design