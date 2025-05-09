# 📁 Add this to a new `quiz_routes.py` file or existing routes module
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models import Sign
from app.dependencies import get_db
import random

router = APIRouter(prefix="/quiz", tags=["Quiz"])

@router.get("/generate/{lesson_id}", summary="Generate smart quiz based on lesson")
async def generate_quiz(lesson_id: int, db: AsyncSession = Depends(get_db)):
    # 🔍 Fetch signs for the lesson
    result = await db.execute(select(Sign).where(Sign.lesson_id == lesson_id, Sign.archived == False))
    signs = result.scalars().all()

    if not signs or len(signs) < 2:
        raise HTTPException(status_code=400, detail="Not enough signs in this lesson to generate a quiz.")

    quiz = []
    for sign in signs:
        # 🎥 1. VIDEO_TO_TEXT: Pick 3 distractors
        distractors = random.sample([s.text for s in signs if s.id != sign.id], k=min(3, len(signs) - 1))
        choices = distractors + [sign.text]
        random.shuffle(choices)

        quiz.append({
            "type": "video_to_text",
            "video_url": sign.video_url,
            "correct_answer": sign.text,
            "choices": choices
        })

        # 📺 2. TEXT_TO_VIDEO: Pick 2 distractor videos
        distractor_videos = random.sample([s.video_url for s in signs if s.id != sign.id], k=min(2, len(signs) - 1))
        video_choices = distractor_videos + [sign.video_url]
        random.shuffle(video_choices)

        quiz.append({
            "type": "text_to_video",
            "question": f"Which video shows the sign for '{sign.text}'?",
            "correct_video": sign.video_url,
            "options": video_choices
        })

    return quiz
