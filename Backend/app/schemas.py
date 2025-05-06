from pydantic import BaseModel, EmailStr, constr, validator
from datetime import datetime
from typing import List, Optional, Dict, Any

class UserSignup(BaseModel):
    name: str
    username: str
    email: EmailStr
    password: constr(min_length=8)
    confirm_password: constr(min_length=8)

    @validator("confirm_password")
    def check_passwords_match(cls, v, values):
        if "password" in values and v != values["password"]:
            raise ValueError("Passwords do not match")
        return v

class UserLogin(BaseModel):
    email: str
    password: str

class AdminLogin(BaseModel):
    email: EmailStr
    password: str

class AccountResponseSchema(BaseModel):
    access_token: str
    token_type: str
    user: Dict[str, Any]

    class Config:
        orm_mode = True

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    profile_url: Optional[str] = None

class UpdateProfilePicture(BaseModel):
    profile_url: str

class ProfilePictureUploadResponse(BaseModel):
    upload_url: str
    file_path: str
    file_url: str

class UserStatusSchema(BaseModel):
    user_id: int
    profile_url: Optional[str] = None
    progress: Any
    rubies: int
    hearts: int
    streak: int
    certificate: bool
    updated_at: datetime

    class Config:
        orm_mode = True

class SignSchema(BaseModel):
    id: int
    text: str
    video_url: str
    difficulty_level: str
    created_at: datetime

    class Config:
        orm_mode = True

class LessonSchema(BaseModel):
    id: int
    unit_id: int
    title: str
    description: Optional[str] = None
    rubies_reward: int = 0
    order_index: int = 0
    image_url: Optional[str] = None
    archived: bool = False
    created_at: datetime
    updated_at: datetime
    progress_bar: int

    class Config:
        orm_mode = True

class LessonResponseSchema(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    signs: List[SignSchema] = []
    rubies_reward: int
    progress_bar: int
    video_url: Optional[str] = None

    class Config:
        orm_mode = True

class UnitSchema(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    order_index: int
    status: str
    created_at: datetime

    class Config:
        orm_mode = True

class UnitWithLessonsSchema(UnitSchema):
    lessons: List[LessonResponseSchema] = []

class UnitUpdateSchema(BaseModel):
    title: str
    description: Optional[str] = None
    order_index: int
    status: str

class ProgressUpdateSchema(BaseModel):
    progress: int
    is_correct: bool
    current_question: int
    hearts_used: int = 0

class ProgressResponseSchema(BaseModel):
    progress: int
    completed: bool
    hearts_remaining: int
    rubies_earned: int = 0
    next_lesson_unlocked: bool = False

class UserProgressSchema(BaseModel):
    progress: int
    completed: bool
    last_question: int
    updated_at: datetime

    class Config:
        orm_mode = True

class UnitProgressResponse(BaseModel):
    progress_percentage: float
    completed_lessons: int
    total_lessons: int

    class Config:
        orm_mode = True

class HeartPurchaseResponse(BaseModel):
    user_id: int
    hearts: int
    rubies: int
    
    class Config:
        orm_mode = True

class HeartPackage(BaseModel):
    id: int
    name: str
    hearts_amount: int
    ruby_cost: int
    
    class Config:
        orm_mode = True

class HeartPurchase(BaseModel):
    user_id: str
    package_id: int


class PracticeSignSchema(BaseModel):
    id: int
    text: str
    video_url: str
    difficulty_level: str

    class Config:
        orm_mode = True

class GameScoreUpdateSchema(BaseModel):
    level_id: int
    game_id: str
    score: int
    hearts_lost: int = 0

class PracticeGameSchema(BaseModel):
    id: int
    game_identifier: str
    name: str
    description: Optional[str] = None
    
    class Config:
        orm_mode = True

class PracticeLevelSchema(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    required_progress: int
    order_index: int
    
    class Config:
        orm_mode = True

class PracticeLevelWithGamesSchema(PracticeLevelSchema):
    games: List[PracticeGameSchema] = []
    unlocked: bool = False
    progress: int = 0
    
    class Config:
        orm_mode = True

class UserPracticeProgressSchema(BaseModel):
    level_id: int
    game_id: int
    high_score: int
    progress: int
    completed: bool
    
    class Config:
        orm_mode = True