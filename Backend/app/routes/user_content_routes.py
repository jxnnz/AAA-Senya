from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models import Unit, Lesson, Sign
from app.dependencies import get_db

router = APIRouter()

@router.get("/units-with-lesson-signs/")
async def get_units_with_lessons_and_signs(db: AsyncSession = Depends(get_db)):
    unit_result = await db.execute(
        select(Unit).where(Unit.archived == False).order_by(Unit.order_index)
    )
    units = unit_result.scalars().unique().all()

    unit_data = []
    for unit in units:
        lesson_result = await db.execute(
            select(Lesson).where(Lesson.unit_id == unit.id, Lesson.archived == False).order_by(Lesson.order_index)
        )
        lessons = lesson_result.scalars().all()

        lesson_data = []
        for lesson in lessons:
            sign_result = await db.execute(
                select(Sign).where(Sign.lesson_id == lesson.id, Sign.archived == False).order_by(Sign.id)
            )
            signs = sign_result.scalars().all()

            lesson_data.append({
                "id": lesson.id,
                "title": lesson.title,
                "description": lesson.description,
                "rubies_reward": lesson.rubies_reward,
                "image_url": lesson.image_url,
                "signs": [
                    {
                        "id": sign.id,
                        "text": sign.text,
                        "video_url": sign.video_url,
                        "difficulty_level": sign.difficulty_level,
                    } for sign in signs
                ]
            })

        unit_data.append({
            "id": unit.id,
            "title": unit.title,
            "description": unit.description,
            "order_index": unit.order_index,
            "lessons": lesson_data
        })

    return unit_data
