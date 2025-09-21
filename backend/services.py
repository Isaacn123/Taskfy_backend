

import jwt as _jwt
import sqlalchemy.orm as _orm
import passlib.hash as _hash
import sqlalchemy as _sql
import email_validator as _checkmail
import fastapi.security as _security
from fastapi import HTTPException, Depends
import dotenv as _env
from typing import Optional

# import database as _database
from database import *
# import schemas as _schema
from schemas import *
# import models as _model
from models import *
import os as _os
import logging

from passlib.context import CryptContext


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

_env.load_dotenv()
JWT_SECRETE = _os.environ.get("JWT_SECRETE", "your-secret-key-here-change-this-in-production")
# helper for checking if one is authendictated
oauth2schema = _security.OAuth2PasswordBearer("/api/token")

logging.basicConfig(level=logging.INFO)

def create_database():

    # return Base.metadata.create_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    logging.info("Database tables created or checked")

async def get_db():
    db= SessionLocal()
    try:
        yield db
    finally:
        db.close()    


def create_user_(user:UserCreate, db:_orm.Session):

    try:
        valid = _checkmail.validate_email(user.email)
        email = valid.email
    except _checkmail.EmailNotValidError:
        raise HTTPException(status_code=400,detail="Please enter a valid email")
    
    user_obj = User(email=email,name=user.name,hashed_password=_hash.bcrypt.hash(user.password))

    db.add(user_obj)
    db.commit()
    db.refresh(user_obj)
    return user_obj


def get_user_by_email(email:str,db:_orm.Session):
    return db.query(User).filter(User.email == email).first()

def create_token(user:User):
    # user_obj = _schema.User.model_validate(user)
    user_obj = user.to_dict()
    # token = _jwt.encode(user_obj.model_dump(),JWT_SECRETE)
    token = _jwt.encode(user_obj,JWT_SECRETE,algorithm="HS256")

    return dict(access_token=token,token_type="bearer")

# def generate_token():
def authenticate_user(email:str,password:str,db:_orm.Session):
    user = get_user_by_email(email=email,db=db)
    # print(f"User: {user.hashed_password}")
    # if not user:
    #     print(f"User: NO USER")
    #     return False
    # if not user.verify_password(password=password):
    #     print(user.verify_password(password=password))
    #     print(f"User: FAILED TO AUTHENTICATE")
    #     return False
    
    # return user
    if user:
        print(f"User found: {user.email}")
        hashed_password2 = _hash.bcrypt.hash(password)
        print(f"Stored hashed password: {user.hashed_password}")
        # print(f"Stored  password: {password}")
        # print(_hash.bcrypt.verify(password,hashed_password2))
        if user.verify_password(password=password):
            print("Password verification successful")
            return user
        else:
            print("Password verification failed")
            return None
    else:
        print("User not Found")
        return None

def get_current_user(db:_orm.Session = Depends(get_db),token:str=Depends(oauth2schema)):

    try:
        payload = _jwt.decode(token,JWT_SECRETE,algorithms=["HS256"])
        # user = db.query(_model.User).get(payload["id"])
        user_id = payload["id"]
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        user = db.query(User).filter(User.id == user_id).first()
        if user is None:
            raise HTTPException(status_code=401,detail="User not found")
        
    except:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    # return User.model_validate(user)
    return user.to_dict()

def create_task(user:User, db:_orm.Session, task:TaskCreate):
    task_data = task.model_dump()
    task_data["owner_id"] = user.id
    task_data["is_completed"] = False
    task = Task(**task_data)
    db.add(task)
    db.commit()
    db.refresh(task)
    return Task.model_validate(task)

def create_user_Task(db:_orm.Session,user_id:int, task:TaskCreate):
    user_task =  Task(**task.model_dump(),owner_id=user_id)
    db.add(user_task)
    db.commit()
    db.refresh(user_task)
    # return Task.model_validate(user_task)
    return user_task


def get_user_task(user:User,db:_orm.Session):
    tasks = db.query(Task).filter(Task.owner_id == user.id).all()
    # return list(map(Task.from_orm,tasks))
    # return [task.model_dump for task in tasks]
    return tasks

def updateTask(
        user:User, 
        task_id:int, 
        db:_orm.Session, 
        task_title:Optional[str] = None, # added the title also
        is_completed:Optional[bool] = None  # is_completed:bool :converting to Optional Field
        ):
    task = db.query(Task).filter(Task.id == task_id,Task.owner_id == user.id).first()

    # if task:
        # task.is_completed = is_completed
    #     db.commit()
    #     return task
    # If the task doesn't exist, raise an error
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    #Update fields only if they are provided
    if is_completed is not None:
        task.is_completed = is_completed

    if task_title is not None:
        task.task_title = task_title
    
    # Commit the changes to the database
    db.commit()
    db.refresh(task)

    return task

def deleteTask(
        user:User, 
        task_id:int, 
        db:_orm.Session, ):
    tasks = db.query(Task).filter(Task.id==task_id,Task.owner_id == user.id).first()

    if not tasks:
        raise HTTPException(status_code=404,detail="Task not found")
    
    db.delete(tasks)
    db.commit()

    return tasks
    # return {"status":200,"msg": "task succefully deleted"}

# Admin functions
def get_current_admin_user(db:_orm.Session = Depends(get_db), token:str=Depends(oauth2schema)):
    """Get current user and verify they are an admin"""
    user = get_current_user(db, token)
    if not user.is_admin():
        raise HTTPException(status_code=403, detail="Admin access required")
    return user

def get_all_users(db:_orm.Session):
    """Get all users (admin only)"""
    users = db.query(User).all()
    return [User(**user.to_dict()) for user in users]

def get_all_tasks(db:_orm.Session):
    """Get all tasks from all users (admin only)"""
    tasks = db.query(Task).all()
    return [Task(id=task.id, task_title=task.task_title, owner_id=task.owner_id, is_completed=task.is_completed, date_created=task.date_created) for task in tasks]

def get_user_by_id(user_id:int, db:_orm.Session):
    """Get user by ID (admin only)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return User(**user.to_dict())

def update_user_admin(user_id:int, user_update, db:_orm.Session):
    """Update user (admin only)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user_update.name is not None:
        user.name = user_update.name
    if user_update.email is not None:
        user.email = user_update.email
    if user_update.role is not None:
        user.role = user_update.role
    
    db.commit()
    db.refresh(user)
    return User(**user.to_dict())

def delete_user_admin(user_id:int, db:_orm.Session):
    """Delete user (admin only)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}

def get_task_by_id(task_id:int, db:_orm.Session):
    """Get task by ID (admin only)"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return Task(id=task.id, task_title=task.task_title, owner_id=task.owner_id, is_completed=task.is_completed, date_created=task.date_created)

def update_task_admin(task_id:int, task_update, db:_orm.Session):
    """Update task (admin only)"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    if task_update.task_title is not None:
        task.task_title = task_update.task_title
    if task_update.is_completed is not None:
        task.is_completed = task_update.is_completed
    if task_update.owner_id is not None:
        task.owner_id = task_update.owner_id
    
    db.commit()
    db.refresh(task)
    return Task(id=task.id, task_title=task.task_title, owner_id=task.owner_id, is_completed=task.is_completed, date_created=task.date_created)

def delete_task_admin(task_id:int, db:_orm.Session):
    """Delete task (admin only)"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    db.delete(task)
    db.commit()
    return {"message": "Task deleted successfully"}

def get_dashboard_stats(db:_orm.Session):
    """Get dashboard statistics (admin only)"""
    total_users = db.query(User).count()
    total_tasks = db.query(Task).count()
    completed_tasks = db.query(Task).filter(Task.is_completed == True).count()
    pending_tasks = total_tasks - completed_tasks
    
    return {
        "total_users": total_users,
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "pending_tasks": pending_tasks,
        "completion_rate": (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
    }
