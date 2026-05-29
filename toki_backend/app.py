from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import json
from pathlib import Path

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent

model = joblib.load(BASE_DIR / "best_recommendation_model.pkl")
context_columns = joblib.load(BASE_DIR / "context_columns.pkl")
item_columns = joblib.load(BASE_DIR / "item_columns.pkl")

with open(BASE_DIR / "arabic_translation.json", "r", encoding="utf-8") as f:
    arabic_translation = json.load(f)


# ── Arabic display labels ────────────────────────────────────────────────────

LOCATION_ARABIC: dict[str, str] = {
    "gym":             "صالة رياضية",
    "university":      "جامعة",
    "masjid_al_haram": "المسجد الحرام",
    "travel":          "سفر",
}

EVENT_ARABIC: dict[str, str] = {
    # Gym
    "Weight Lifting": "رفع الأثقال",
    "Cardio":         "كارديو",
    "Boxing":         "ملاكمة",
    "Yoga":           "يوغا",
    "Swimming":       "سباحة",
    "Pilates":        "بيلاتيس",
    "Soccer":         "كرة القدم",
    # University
    "Lectures":       "محاضرات",
    "Exam":           "اختبار",
    # Masjid al-Haram
    "Hajj":           "حج",
    "Umrah":          "عمرة",
    # Travel
    "Makkah":         "مكة المكرمة",
    "Vacation":       "إجازة",
    "Business":       "رحلة عمل",
}


# ── Fuzzy location normalization ────────────────────────────────────────────

LOCATION_KEYWORDS: dict[str, list[str]] = {
    "gym": [
        "gym", "fitness", "workout", "exercise", "sport", "sports",
        "training", "lifting", "weights", "cardio", "crossfit",
        "swimming", "yoga",

        "جيم", "صالة", "صاله", "رياضة", "رياضه",
        "تمرين", "تمارين", "لياقة", "لياقه",
        "تمارين لياقة", "تمارين لياقه",
        "كارديو", "كروس فت", "رفع أثقال", "أثقال",
        "سباحة", "سباحه", "يوجا",
        "صالة رياضية", "صاله رياضيه",
    ],

    "university": [
        "university", "college", "school", "campus",
        "lecture", "study", "studies", "academic",

        "جامعة", "جامعه", "كلية", "كليه",
        "مدرسة", "مدرسه", "دراسة", "دراسه",
        "دراسات", "محاضرة", "محاضره",
        "أكاديمي",
    ],

    "masjid_al_haram": [
        "haram", "makkah", "mecca", "masjid al haram", "masjid alharam",
        "hajj", "umrah", "pilgrimage",

        "الحرم", "مكة", "مكه", "مسجد الحرام",
        "حج", "عمرة", "عمره",
        "اعتمار", "البيت الحرام",
    ],

    "travel": [
        "travel", "trip", "vacation", "holiday", "airport",
        "flight", "journey", "abroad", "business trip",

        "سفر", "رحلة", "رحله",
        "إجازة", "إجازه",
        "عطلة", "عطله",
        "مطار", "طيران",
        "رحلة عمل", "رحله عمل",
        "خارج",
    ],
}


_KEYWORD_MAP: dict[str, str] = {}

for canonical, keywords in LOCATION_KEYWORDS.items():
    for kw in keywords:
        _KEYWORD_MAP[kw.lower()] = canonical


def normalize_location(raw: str) -> str | None:
    text = raw.strip().lower()

    if text in _KEYWORD_MAP:
        return _KEYWORD_MAP[text]

    for kw, canonical in _KEYWORD_MAP.items():
        if kw in text:
            return canonical

    return None


# ── Pydantic models ──────────────────────────────────────────────────────────

class LocationRequest(BaseModel):
    list_name: str


class RecommendationRequest(BaseModel):
    list_name: str
    event: str
    period: str
    weather: str
    gender: str
    role: str
    top_n: int = 15


# ── Helpers ──────────────────────────────────────────────────────────────────

def clean_value(value):
    return (
        str(value)
        .lower()
        .replace(" ", "_")
        .replace("-", "_")
        .strip()
    )


def normalize_item_name(item):
    return (
        str(item)
        .replace("item__", "")
        .replace("_", " ")
        .strip()
    )


def activate_context_column(input_data, category, value):
    clean_category = str(category).lower().strip()
    clean_val = clean_value(value)

    target = f"context__{clean_category}_{clean_val}"

    for col in input_data.columns:
        if str(col).lower().strip() == target:
            input_data[col] = 1
            return True

    print(f"Warning: column not found for {category} = {value}")
    print(f"Expected column: {target}")
    return False


def create_user_input(list_name, event, period, weather, gender, role):
    input_data = pd.DataFrame(
        0,
        index=[0],
        columns=context_columns,
    )

    activate_context_column(input_data, "list_name", list_name)
    activate_context_column(input_data, "event", event)
    activate_context_column(input_data, "period", period)
    activate_context_column(input_data, "weather", weather)
    activate_context_column(input_data, "gender", gender)
    activate_context_column(input_data, "role", role)

    return input_data


def get_score_matrix(model, X_data):
    if hasattr(model, "predict_proba"):
        probabilities = model.predict_proba(X_data)

        score_matrix = np.zeros((X_data.shape[0], len(item_columns)))

        for i, prob in enumerate(probabilities):
            if i < len(item_columns):
                if len(prob.shape) == 2 and prob.shape[1] == 2:
                    score_matrix[:, i] = prob[:, 1]
                elif len(prob.shape) == 2 and prob.shape[1] == 1:
                    score_matrix[:, i] = prob[:, 0]
                else:
                    score_matrix[:, i] = 0

        return score_matrix

    return model.predict(X_data)


def build_events_payload(canonical: str | None) -> list[dict]:
    """Return events as a list of {english, arabic} dicts for the given location."""
    location_events: dict[str, list[str]] = {
        "gym": [
            "Weight Lifting",
            "Cardio",
            "Boxing",
            "Yoga",
            "Swimming",
            "Pilates",
            "Soccer",
        ],
        "university": [
            "Lectures",
            "Exam",
        ],
        "masjid_al_haram": [
            "Hajj",
            "Umrah",
        ],
        "travel": [
            "Makkah",
            "Vacation",
            "Business",
        ],
    }

    english_events = location_events.get(canonical, []) if canonical else []

    return [
        {"english": e, "arabic": EVENT_ARABIC.get(e, e)}
        for e in english_events
    ]


# ── Routes ───────────────────────────────────────────────────────────────────

@app.get("/")
def home():
    return {
        "message": "Toki ML backend is running",
        "inputs": ["list_name", "event", "period", "weather", "gender", "role"],
        "available_files_loaded": {
            "model": True,
            "context_columns": len(context_columns),
            "item_columns": len(item_columns),
            "arabic_translations": len(arabic_translation),
        },
    }


@app.post("/normalize_location")
def normalize_location_endpoint(req: LocationRequest):
    canonical = normalize_location(req.list_name)
    events = build_events_payload(canonical)

    return {
        "canonical": canonical,
        "matched": canonical is not None,
        "arabic_location": LOCATION_ARABIC.get(canonical, canonical) if canonical else None,

        "events": [e["english"] for e in events],

        "events_localized": events,
    }


@app.post("/events_for_location")
def events_for_location(req: LocationRequest):
    canonical = normalize_location(req.list_name)
    events = build_events_payload(canonical)

    return {
        "matched": canonical is not None,

        "events": [e["english"] for e in events],

        "events_localized": events,
    }


@app.post("/recommend")
def recommend(request: RecommendationRequest):
    canonical_list = normalize_location(request.list_name) or request.list_name

    user_input = create_user_input(
        list_name=canonical_list,
        event=request.event,
        period=request.period,
        weather=request.weather,
        gender=request.gender,
        role=request.role,
    )

    score_matrix = get_score_matrix(model, user_input)
    scores = score_matrix[0]

    score_df = pd.DataFrame({
        "item_column": item_columns,
        "score": scores,
    })

    SCORE_THRESHOLD = 0.15

    score_df = score_df[score_df["score"] >= SCORE_THRESHOLD]
    score_df = score_df.sort_values(by="score", ascending=False).head(request.top_n)

    english_items = [
        normalize_item_name(item)
        for item in score_df["item_column"].tolist()
    ]

    arabic_items = [
        arabic_translation.get(item, item)
        for item in english_items
    ]

    return {
        "arabic_items": arabic_items,
        "english_items": english_items,
        "scores": score_df["score"].tolist(),
    }