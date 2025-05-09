# 📁 app/routes/admin_dashboard.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models import Unit, Lesson
from app.dependencies import get_db, get_current_user
from app.models import Account
from sqlalchemy import select, func
from sqlalchemy.sql import literal_column
from fastapi import status
from app.models import Sign

router = APIRouter(tags=["Admin Dashboard"])

@router.get("/summary", summary="Get admin dashboard summary")
async def get_admin_summary(
    db: AsyncSession = Depends(get_db),
    current_user: Account = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admins only")

    try:
        total_units = (await db.execute(select(func.count(Unit.id)).where(Unit.archived == False))).scalar() or 0
        archived_units = (await db.execute(select(func.count(Unit.id)).where(Unit.archived == True))).scalar() or 0

        total_lessons = (await db.execute(select(func.count(Lesson.id)).where(Lesson.archived == False))).scalar() or 0
        archived_lessons = (await db.execute(select(func.count(Lesson.id)).where(Lesson.archived == True))).scalar() or 0

        total_signs = (await db.execute(select(func.count(Sign.id)).where(Sign.archived == False))).scalar() or 0
        archived_signs = (await db.execute(select(func.count(Sign.id)).where(Sign.archived == True))).scalar() or 0

        rubies = (
            await db.execute(select(func.coalesce(func.sum(Lesson.rubies_reward), 0)).where(Lesson.archived == False))
        ).scalar() or 0

        return {
            "units": total_units,
            "lessons": total_lessons,
            "signs": total_signs,
            "archived": {
                "units": archived_units,
                "lessons": archived_lessons,
                "signs": archived_signs,
            },
            "total_rubies": rubies,
        }

    except Exception as e:
        print("🔥 SUMMARY ERROR:", e)
        raise HTTPException(status_code=500, detail="Summary error")

@router.get("/lessons-per-unit")
async def get_lessons_per_unit(
    db: AsyncSession = Depends(get_db),
    current_user: Account = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admins only")

    result = await db.execute(
        select(Unit.id, Unit.title, func.count(Lesson.id).label("lesson_count"))
        .join(Lesson, Lesson.unit_id == Unit.id, isouter=True)
        .where(Unit.archived == False)
        .where(Lesson.archived == False)
        .group_by(Unit.id, Unit.title)
        .order_by(Unit.order_index)
    )
    rows = result.fetchall()

    return [
        {
            "unit_id": r.id,
            "unit_title": r.title,
            "lesson_count": r.lesson_count,
        }
        for r in rows
    ]

@router.get("/signs-per-lesson", summary="Get number of signs per lesson")
async def get_signs_per_lesson(
    db: AsyncSession = Depends(get_db),
    current_user: Account = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admins only")

    result = await db.execute(
        """
        SELECT l.id AS lesson_id, l.title AS lesson_title, COUNT(s.id) AS sign_count
        FROM lessons l
        LEFT JOIN signs s ON s.lesson_id = l.id AND s.archived = FALSE
        WHERE l.archived = FALSE
        GROUP BY l.id, l.title
        ORDER BY l.lesson_no ASC
        """
    )

    rows = result.fetchall()

    return [
        {
            "lesson_id": row.lesson_id,
            "lesson_title": row.lesson_title,
            "sign_count": row.sign_count,
        }
        for row in rows
    ]

@router.get("/signs-difficulty-summary", summary="Get total signs per difficulty level")
async def get_sign_difficulty_summary(
    db: AsyncSession = Depends(get_db),
    current_user: Account = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admins only")

    result = await db.execute(
        """
        SELECT difficulty, COUNT(*) as count
        FROM signs
        WHERE archived = FALSE
        GROUP BY difficulty
        """
    )

    rows = result.fetchall()

    summary = {"beginner": 0, "intermediate": 0, "advanced": 0}

    for row in rows:
        if row.difficulty in summary:
            summary[row.difficulty] = row.count

    return summary

@router.get("/user-performance", summary="Get user difficulty insights")
async def get_user_performance(
    db: AsyncSession = Depends(get_db),
    current_user: Account = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admins only")

    # 🔥 Most failed lessons
    failed_query = await db.execute("""
        SELECT lesson_id, COUNT(*) AS fail_count
        FROM user_progress
        WHERE completed = 0
        GROUP BY lesson_id
        ORDER BY fail_count DESC
        LIMIT 5
    """)
    failed_lessons = failed_query.fetchall()

    # 🔁 Most repeated lessons
    repeat_query = await db.execute("""
        SELECT lesson_id, COUNT(*) AS repeat_count
        FROM user_progress
        WHERE `repeat` = TRUE
        GROUP BY lesson_id
        ORDER BY repeat_count DESC
        LIMIT 5
    """)
    repeat_lessons = repeat_query.fetchall()

    # 🕓 Slowest lessons by average time
    time_query = await db.execute("""
        SELECT lesson_id, AVG(time_spent) AS avg_time
        FROM user_progress
        WHERE time_spent IS NOT NULL
        GROUP BY lesson_id
        ORDER BY avg_time DESC
        LIMIT 5
    """)
    slowest_lessons = time_query.fetchall()

    def format_lesson(row, key):
        return {
            "lesson_id": row.lesson_id,
            "lesson_title": f"Lesson {row.lesson_id}",  # (Can be replaced by JOIN for actual titles)
            key: getattr(row, key)
        }

    return {
        "most_failed": [format_lesson(row, "fail_count") for row in failed_lessons],
        "most_repeated": [format_lesson(row, "repeat_count") for row in repeat_lessons],
        "slowest_lessons": [format_lesson(row, "avg_time") for row in slowest_lessons],
    }

