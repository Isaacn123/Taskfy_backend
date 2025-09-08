from pydantic import BaseModel
import sqlalchemy as  _sql
import datetime as _dt

class _BaseUser(BaseModel):
    email:str
    name:str

class UserCreate(_BaseUser):
    password:str
    role:str = "user"  # Default to user role

    class Config:
        from_attributes=True

class User(_BaseUser):
    id:int
    role:str
    date_created:_dt.datetime

    class Config:
        from_attributes = True

# Admin-specific schemas
class AdminUserUpdate(BaseModel):
    name: str | None = None
    email: str | None = None
    role: str | None = None

class AdminTaskUpdate(BaseModel):
    task_title: str | None = None
    is_completed: bool | None = None
    owner_id: int | None = None

class _TaskBase(BaseModel):
    task_title:str

class TaskCreate(_TaskBase):
   pass

class Task(_TaskBase):
    id:int
    owner_id:int
    is_completed:bool = False
    date_created:_dt.datetime

    class Config:
        from_attributes = True




