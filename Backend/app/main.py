import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from app.config import DATABASE_URL
from app import models
from app.db import engine
import os
from pathlib import Path
from fastapi.staticfiles import StaticFiles
from app.routes import admin_dashboard
from app.routes import user_content_routes
from app.routes.quiz_routes import router as quiz_router



app = FastAPI(title="Senya Sign Language App")

from app.routes import ( practice_routes, auth_routes, lessons_routes, shop_routes, profile_routes, admin_units, admin_lessons, admin_signs, user_routes, recognition_routes )
app.include_router(user_content_routes.router, prefix="/api/lessons", tags=["Lessons"])
app.include_router(quiz_router, prefix="/api")


app.mount("/static", StaticFiles(directory="static"), name="static")
app.include_router(
    admin_dashboard.router,
    prefix="/api/admin/dashboard",
    tags=["Admin Dashboard"]
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

static_dir = Path("static")
os.makedirs(static_dir, exist_ok=True)
app.mount("/static", StaticFiles(directory=static_dir), name="static")


app.include_router(practice_routes.router, prefix="/api/practice", tags=["Practice"])
app.include_router(admin_units.router, prefix="/api/admin/units", tags=["Admin Units"])
app.include_router(admin_lessons.router, prefix="/api/admin/lessons", tags=["Admin Lessons"])
app.include_router(admin_signs.router, prefix="/api/admin/signs", tags=["Admin Signs"])
app.include_router(auth_routes.router, prefix="/api/auth", tags=["Auth"])
app.include_router(lessons_routes.router, prefix="/api/lessons", tags=["Lessons"])
app.include_router(user_routes.router, prefix="/api/status", tags=["Status"])
app.include_router(profile_routes.router, prefix="/api/profile", tags=["Profile"])
app.include_router(shop_routes.router, prefix="/api/shop", tags=["Shop"])
app.include_router(recognition_routes.router, prefix="/api/recognition", tags=["Recognition"])

@app.on_event("startup")
async def on_startup():
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)


if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)