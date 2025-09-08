import logging
from fastapi import FastAPI,Depends,status, HTTPException, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
import sqlalchemy.orm as _orm
from typing import Union,List
import fastapi.security as _security
from typing import Optional
from itsdangerous import URLSafeTimedSerializer
import secrets

from services import  create_database, get_db, get_current_user,get_user_by_email,create_token,create_task,create_user_,create_user_Task,authenticate_user,get_user_task,updateTask,deleteTask,get_current_admin_user,get_all_users,get_all_tasks,get_user_by_id,update_user_admin,delete_user_admin,get_task_by_id,update_task_admin,delete_task_admin,get_dashboard_stats
# import schemas as _schema
from schemas import UserCreate,Task,TaskCreate,User,AdminUserUpdate,AdminTaskUpdate
# import models as _model
# from .schemas import *
# from .models import User


app = FastAPI()
template = Jinja2Templates(directory="templates")

# Flash message configuration
SECRET_KEY = "your-secret-key-here"  # Change this to a secure secret key
serializer = URLSafeTimedSerializer(SECRET_KEY)

# Flash message functions
def flash(request: Request, message: str, category: str = "info"):
    """Add a flash message to the session"""
    if not hasattr(request.state, 'flash_messages'):
        request.state.flash_messages = []
    request.state.flash_messages.append({"message": message, "category": category})

def get_flashed_messages(request: Request):
    """Get flash messages from the session"""
    if hasattr(request.state, 'flash_messages'):
        messages = request.state.flash_messages
        request.state.flash_messages = []
        return messages
    return []

# Add flash functions to template context
template.env.globals.update({
    'get_flashed_messages': lambda request: get_flashed_messages(request)
})

@app.on_event("startup")
async def startup():
    # This will run only once when the app starts
    create_database()
    logging.info("Database initialized successfully.")

@app.get('/')
def read_root(request: Request):
    # Example of adding a flash message
    flash(request, "Welcome to Taskify!", "success")
    return template.TemplateResponse("dashboard.html", {"request": request})

@app.post('/api/user')
async def create_user(user:UserCreate, db:_orm.Session = Depends(get_db)):

    user_db = get_user_by_email(user.email,db)

    if user_db:
        raise HTTPException(status_code=400,detail="Email already Exits")
    
    # user = _service.create_user_(user,db)
    user = create_user_(user,db)
    return create_token(user)

@app.post("/api/token") 
def generate_token(
    form_data:_security.OAuth2PasswordRequestForm = Depends(),db:_orm.Session = Depends(get_db)
):
    print("Received form data:")
    # print(f"Username: {form_data.username}")
    # print(f"Password: {form_data.password}")

    user = authenticate_user(email=form_data.username,password=form_data.password, db=db)

    print("Authenticated user:")
    print(user)

    if not user:
        print("User authentication failed")
        raise HTTPException(status_code=400,detail="Invalid Credentials")
    
    return create_token(user=user)


@app.get("/api/user/me", response_model=User)
def get_user(user:User = Depends(get_current_user)):
    return user



@app.post('/api/user/tasks', response_model=Task)
def create_task(task:TaskCreate,user:User =Depends(get_current_user), db:_orm.Session = Depends(get_db)):
    return create_task(user=user,db=db,task=task)

@app.post("/users/user/{user_id}/tasks", response_model=Task)
def create_user_task(user_id:int,task:TaskCreate,user:User = Depends(get_current_user),db:_orm.Session =Depends(get_db)):
    return create_user_Task(db=db,user_id=user_id,task=task)


@app.get("/api/tasks",response_model=List[Task])
async def get_user_tasks(user:User = Depends(get_current_user), db:_orm.Session = Depends(get_db)):
    return get_user_task(user=user,db=db)

@app.put("/api/task/{task_id}", response_model=Task)
async def update_task(
        task_id: int,
        is_completed: Optional[bool] = None,
        task_title: Optional[str] = None,
        user:User = Depends(get_current_user), 
        db:_orm.Session = Depends(get_db)):
    return updateTask(task_id=task_id, user=user,db=db,is_completed=is_completed, task_title=task_title)          

@app.delete("/api/task/{task_id}",response_model=Task)
async def delete_task(
    task_id:int,
    user:User = Depends(get_current_user),
    db: _orm.Session = Depends(get_db)):

    return deleteTask(user=user,db=db,task_id=task_id)

# Admin Routes
@app.get("/admin/dashboard")
async def admin_dashboard(
    request: Request,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Admin dashboard with statistics"""
    stats = get_dashboard_stats(db)
    return template.TemplateResponse("admin_dashboard.html", {
        "request": request,
        "stats": stats,
        "admin": admin
    })

@app.get("/admin/users", response_model=List[User])
async def admin_get_all_users(
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Get all users (admin only)"""
    return get_all_users(db)

@app.get("/admin/tasks", response_model=List[Task])
async def admin_get_all_tasks(
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Get all tasks (admin only)"""
    return get_all_tasks(db)

@app.get("/admin/users/{user_id}", response_model=User)
async def admin_get_user(
    user_id: int,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Get specific user (admin only)"""
    return get_user_by_id(user_id, db)

@app.put("/admin/users/{user_id}", response_model=User)
async def admin_update_user(
    user_id: int,
    user_update: AdminUserUpdate,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Update user (admin only)"""
    return update_user_admin(user_id, user_update, db)

@app.delete("/admin/users/{user_id}")
async def admin_delete_user(
    user_id: int,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Delete user (admin only)"""
    return delete_user_admin(user_id, db)

@app.get("/admin/tasks/{task_id}", response_model=Task)
async def admin_get_task(
    task_id: int,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Get specific task (admin only)"""
    return get_task_by_id(task_id, db)

@app.put("/admin/tasks/{task_id}", response_model=Task)
async def admin_update_task(
    task_id: int,
    task_update: AdminTaskUpdate,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Update task (admin only)"""
    return update_task_admin(task_id, task_update, db)

@app.delete("/admin/tasks/{task_id}")
async def admin_delete_task(
    task_id: int,
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Delete task (admin only)"""
    return delete_task_admin(task_id, db)

@app.get("/admin/stats")
async def admin_stats(
    admin: User = Depends(get_current_admin_user),
    db: _orm.Session = Depends(get_db)
):
    """Get dashboard statistics (admin only)"""
    return get_dashboard_stats(db)

@app.get("/admin/simple/tasks")
async def simple_admin_tasks(request: Request, db: _orm.Session = Depends(get_db)):
    """Get all tasks"""
    tasks = get_all_tasks(db)
    return template.TemplateResponse("all_tasks.html", {
        "request": request,
        "tasks": tasks
    })

@app.get("/admin/simple/users")
async def simple_admin_users(request: Request, db: _orm.Session = Depends(get_db)):
    """Get all users"""
    users = get_all_users(db)
    return template.TemplateResponse("all_users.html", {
        "request": request,
        "users": users
    })

# Simple Admin Dashboard
@app.get("/admin/simple")
async def simple_admin_dashboard(request: Request, db: _orm.Session = Depends(get_db)):
    """Simple admin dashboard - no authentication required"""
    stats = get_dashboard_stats(db)
    return template.TemplateResponse("simple_admin.html", {
        "request": request,
        "stats": stats
    })


