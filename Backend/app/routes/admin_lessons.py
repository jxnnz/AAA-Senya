from fastapi import APIRouter, Depends, HTTPException, status, Form, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import update
from app.models import Lesson, Unit, Sign
from app.dependencies import get_db, get_admin_user
from app.schemas import LessonSchema
from typing import List
from fastapi import UploadFile, File
import shutil, uuid, os
from pathlib import Path

router = APIRouter()

@router.get("/unit/{unit_id}", response_model=List[LessonSchema])
async def get_lessons_by_unit(
    unit_id: int,
    include_archived: bool = Query(False, description="Include archived lessons"),
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_admin_user)
):
    query = select(Lesson).where(Lesson.unit_id == unit_id).order_by(Lesson.order_index)
    
    if not include_archived:
        query = query.where(Lesson.archived == False)
        
    result = await db.execute(query)
    lessons = result.scalars().all()
    return lessons


@router.post("/", response_model=LessonSchema, status_code=status.HTTP_201_CREATED)
async def create_lesson(
    unit_id: int = Form(...),
    title: str = Form(...),
    description: str = Form(None),
    rubies_reward: int = Form(0),
    order_index: int = Form(...),
    image_url: str = Form(None),
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_admin_user)
):
    unit_result = await db.execute(select(Unit).where(Unit.id == unit_id))
    unit = unit_result.scalars().first()
    if not unit:
        raise HTTPException(status_code=404, detail="Unit not found")
    
    new_lesson = Lesson(
        unit_id=unit_id,
        title=title,
        description=description,
        rubies_reward=rubies_reward,
        order_index=order_index,
        image_url=image_url,
        archived=False
    )
    db.add(new_lesson)
    await db.commit()
    await db.refresh(new_lesson)
    return new_lesson

@router.put("/{lesson_id}", response_model=LessonSchema)
async def update_lesson(
    lesson_id: int,
    unit_id: int = Form(...),
    title: str = Form(...),
    description: str = Form(None),
    rubies_reward: int = Form(0),
    order_index: int = Form(...),
    image_url: str = Form(None),
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_admin_user)
):
    result = await db.execute(select(Lesson).where(Lesson.id == lesson_id))
    lesson = result.scalars().first()
    
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    lesson.unit_id = unit_id
    lesson.title = title
    lesson.description = description
    lesson.rubies_reward = rubies_reward
    lesson.order_index = order_index
    lesson.image_url = image_url
    
    await db.commit()
    await db.refresh(lesson)
    return lesson

@router.patch("/{lesson_id}/archive", response_model=LessonSchema)
async def archive_lesson(
    lesson_id: int,
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_admin_user)
):
    result = await db.execute(select(Lesson).where(Lesson.id == lesson_id))
    lesson = result.scalars().first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")

    lesson.archived = True

    await db.execute(
        update(Sign)
        .where(Sign.lesson_id == lesson_id)
        .values(archived=True)
    )

    await db.commit()
    await db.refresh(lesson)
    return lesson

@router.get("/", response_model=List[LessonSchema])
async def get_all_lessons(
    include_archived: bool = Query(False, description="Include archived lessons"),
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_admin_user)
):
    query = select(Lesson).order_by(Lesson.unit_id, Lesson.order_index)
    if not include_archived:
        query = query.where(Lesson.archived == False)
    result = await db.execute(query)
    return result.scalars().all()

LESSON_IMAGE_DIR = Path("static/images/lessons")
os.makedirs(LESSON_IMAGE_DIR, exist_ok=True)
LESSON_IMAGE_BASE = "/static/images/lessons"

@router.post("/{lesson_id}/upload-image")
async def upload_lesson_image(
    lesson_id: int,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_admin_user)
):
    result = await db.execute(select(Lesson).where(Lesson.id == lesson_id))
    lesson = result.scalars().first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")

    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid file type")

    ext = os.path.splitext(file.filename)[1]
    filename = f"{uuid.uuid4()}{ext}"

    folder = LESSON_IMAGE_DIR / str(lesson_id)
    os.makedirs(folder, exist_ok=True)
    file_path = folder / filename

    try:
        with open(file_path, "wb") as f:
            shutil.copyfileobj(file.file, f)
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to save image")
    finally:
        file.file.close()

    # Save path to DB
    lesson.image_url = f"{LESSON_IMAGE_BASE}/{lesson_id}/{filename}"
    await db.commit()
    await db.refresh(lesson)

    return {
        "success": True,
        "image_url": lesson.image_url,
        "msg": "Image uploaded successfully"
    }
